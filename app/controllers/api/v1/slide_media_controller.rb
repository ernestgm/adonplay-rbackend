module Api
  module V1
    class SlideMediaController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_slide_media, only: [:show, :update]
      before_action :verify_slide_media_ownership, only: [:show, :update]
      before_action :verify_slide_ownership, only: [:create, :update]
      before_action :verify_media_ownership, only: [:create, :update]
      before_action :verify_audio_media_ownership, only: [:create, :update]
      before_action :verify_qr_ownership, only: [:create, :update]
      after_action :notify_changes, only: [:create, :update]

      ENVIRONMENT = Rails.application.config.local_storage[:environment]
      
      # GET /api/v1/slides/:slide_id/media
      def index
        @slide = Slide.find(params[:slide_id])
        
        # Verify ownership of the slide
        unless current_user.role == 'admin' || @slide.business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only access media for slides that belong to your businesses' }, status: :forbidden
          return
        end
        
        @slide_media = @slide.slide_medias.order(:order)
        
        render json: @slide_media.map { |slide_media| SlideMediaSerializer.new(slide_media).as_json }, status: :ok
      end
      
      # GET /api/v1/slide_media/:id
      def show
        render json: SlideMediaSerializer.new(@slide_media).as_json, status: :ok
      end
      
      # POST /api/v1/slide_media
      def create
        @slide_media = SlideMedia.new(slide_media_params)

        # Find the highest existing order for the current slide
        # Use `where(slide_id: @slide_media.slide_id)` to scope it to the current slide
        # Use `maximum(:order)` to get the highest order value
        last_order = SlideMedia.where(slide_id: @slide_media.slide_id).maximum(:order)

        # Determine the new order
        if last_order.nil?
          # If no existing items for this slide, set order to 0
          @slide_media.order = 0
        else
          # Otherwise, set order to the last order + 1
          @slide_media.order = last_order + 1
        end

        if @slide_media.save
          render json: SlideMediaSerializer.new(@slide_media).as_json, status: :created
        else
          render json: { errors: format_errors(@slide_media) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/slide_media/:id
      def update
        permitted_params = slide_media_params

        if @slide_media.update(permitted_params)
          render json: SlideMediaSerializer.new(@slide_media).as_json, status: :ok
        else
          render json: { errors: format_errors(@slide_media) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/slide_media

      def destroy
        if params[:ids].present?
          # Bulk QR deletion
          slide_medias_ids = params[:ids].map(&:to_i)

          # Scope to QRs owned by current user if not admin
          slides_medias = scope_slides_to_owner(SlideMedia.where(id: slide_medias_ids))

          affected_device_ids = slides_medias.includes(:slide => :devices)
                                             .flat_map { |sm| sm.slide.devices.pluck(:device_id) }
                                             .uniq

          deleted_count = slides_medias.destroy_all.count

          affected_device_ids.each do |device_id|
            action_data = {
              type: "ejecute_data_change", # Tipo de acción para que el cliente la interprete
              payload: {
                updated_at: slide_medias_ids,
                msg: "Slide Media Notify Changes"
              }
            }
            ChangeDevicesActionsChannel.broadcast_to(
              device_id, # El identificador de la aplicación
              action_data
            )
          end

          render json: {
            message: "#{deleted_count} Items deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No QR IDs provided' }, status: :bad_request
        end
      end
      
      # POST /api/v1/slides/:slide_id/media/reorder
      def reorder
        @slide = Slide.find(params[:slide_id])
        
        # Verify ownership of the slide
        unless current_user.role == 'admin' || @slide.business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only reorder media for slides that belong to your businesses' }, status: :forbidden
          return
        end
        
        # Validate the order parameter
        unless params[:order].is_a?(Array) && params[:order].all? { |id| id.is_a?(Integer) }
          render json: { error: 'Invalid order parameter. Expected an array of media IDs.' }, status: :bad_request
          return
        end
        
        # Get all slide_media records for this slide
        slide_media_records = @slide.slide_medias.where(media_id: params[:order])
        
        # Check if all media IDs in the order array exist for this slide
        if slide_media_records.count != params[:order].count
          render json: { error: 'Some media IDs in the order array do not exist for this slide.' }, status: :bad_request
          return
        end
        
        # Update the order of each slide_media record
        ActiveRecord::Base.transaction do
          params[:order].each_with_index do |media_id, index|
            slide_media = slide_media_records.find { |sm| sm.media_id == media_id }
            slide_media.update!(order: index)
          end
        end
        
        render json: { message: 'Media reordered successfully' }, status: :ok
      end
      
      private

      def notify_changes
        return unless @slide_media&.persisted?

        @slide_media.slide.devices.each do |device|
          action_data = {
            type: "ejecute_data_change", # Tipo de acción para que el cliente la interprete
            payload: {
              updated_at: @slide_media.updated_at,
              msg: "Slide Media Notify Changes"
            }
          }
          ChangeDevicesActionsChannel.broadcast_to(
            device.device_id, # El identificador de la aplicación
            action_data
          )
        end
      end
      def set_slide_media
        @slide_media = SlideMedia.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Slide media not found' }, status: :not_found
      end
      
      def slide_media_params
        # Support direct JSON format without nesting
        params.permit(:slide_id, :media_id, :order, :duration, :audio_media_id, :qr_id, :description, :text_size, :description_position)
      end
      
      def verify_slide_media_ownership
        return if current_user.role == 'admin'
        
        # Check if the slide belongs to a business owned by the current user
        unless @slide_media.slide.business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only access slide media for slides that belong to your businesses' }, status: :forbidden
        end
      end
      
      def verify_slide_ownership
        slide_id = params[:slide_id]
        return if current_user.role == 'admin' || !slide_id
        
        slide = Slide.find_by(id: slide_id)
        unless slide && slide.business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only create slide media for slides that belong to your businesses' }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Slide not found' }, status: :not_found
      end
      
      def verify_media_ownership
        media_id = params[:media_id]
        return if current_user.role == 'admin' || !media_id
        
        media = Media.find_by(id: media_id)
        
        # Check if the current user is the owner of the media
        return if media && media.owner_id == current_user.id
        
        # For backward compatibility, check associations
        if media
          # Check if the media is associated with any slides that belong to businesses owned by the current user
          slide_count = media.slides.joins(:business).where(business: { owner_id: current_user.id }).count

          return if slide_count > 0
        end
        
        render json: { error: 'Unauthorized: You can only use media that you own or that is associated with your businesses' }, status: :forbidden
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Media not found' }, status: :not_found
      end
      
      def verify_audio_media_ownership
        audio_media_id = params[:audio_media_id]
        return if current_user.role == 'admin' || !audio_media_id
        
        audio_media = Media.find_by(id: audio_media_id)
        
        # Check if the current user is the owner of the audio media
        return if audio_media && audio_media.owner_id == current_user.id
        
        # For backward compatibility, check associations
        if audio_media
          # Check if the audio media is associated with any slides that belong to businesses owned by the current user
          slide_count = audio_media.slides.joins(:business).where(business: { owner_id: current_user.id }).count
          
          return if slide_count > 0
        end
        
        render json: { error: 'Unauthorized: You can only use audio media that you own or that is associated with your businesses' }, status: :forbidden
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Audio media not found' }, status: :not_found
      end
      
      def verify_qr_ownership
        qr_id = params[:qr_id]
        return if current_user.role == 'admin' || !qr_id
        
        qr = Qr.find_by(id: qr_id)
        unless qr && qr.business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only use QRs that belong to your businesses' }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'QR not found' }, status: :not_found
      end
    end
  end
end