module Api
  module V1
    class MediaController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter

      before_action :authenticate_request
      before_action :set_media, only: [:show, :update]
      before_action :verify_media_ownership, only: [:show, :update]
      after_action :notify_changes, only: [:update]

      # Get the environment (desa or prod)
      ENVIRONMENT = Rails.application.config.local_storage[:environment]

      # GET /api/v1/media
      def index
        if current_user.role == 'admin'
          @media = Media.all
        else
          # For owner, get media they own directly
          @media = Media.where(owner_id: current_user.id)
        end

        # Filter by media type if provided
        if params[:media_type].present?
          @media = @media.where(media_type: params[:media_type])
        end

        render json: @media.map { |media| MediaSerializer.new(media).as_json }, status: :ok
      end

      # GET /api/v1/medias_excepted/:slide_id
      def index_excepted
        specific_slide_id = params[:slide_id]

        # Validamos que el slide_id esté presente para evitar errores
        return render json: { error: 'Slide ID is required' }, status: :bad_request if specific_slide_id.blank?

        # 1. Buscamos los IDs ya vinculados (como es unique, no habrá duplicados aquí)
        used_media_ids = SlideMedia.where(slide_id: specific_slide_id).pluck(:media_id)

        # 2. Construimos la consulta base según el rol
        if current_user.role == 'admin'
          @slide = Slide.find_by(id: specific_slide_id)
          return render json: { error: 'Slide not found' }, status: :not_found unless @slide

          owner_id = @slide.business.owner_id
          media_table = Media.arel_table

          @media = Media.where.not(media_type: "audio")
                        .where(
                          media_table[:owner_id].eq(owner_id)
                                                .or(media_table[:owner_id].eq(current_user.id))
                        )
        else
          @media = Media.where(owner_id: current_user.id)
                        .where.not(media_type: "audio")
        end

        # 3. Excluimos los IDs usados
        # Rails genera un "WHERE id NOT IN (...)" automáticamente
        @media = @media.where.not(id: used_media_ids) if used_media_ids.present?

        render json: @media.map { |media| MediaSerializer.new(media).as_json }, status: :ok
      end

      # GET /api/v1/all_audio_excepted/:slide_id
      def all_audio_excepted
        specific_slide_id = params[:slide_id]

        # 1. Validación inicial
        return render json: { error: 'Slide ID is required' }, status: :bad_request if specific_slide_id.blank?

        @slide = Slide.find_by(id: specific_slide_id)
        return render json: { error: 'Slide not found' }, status: :not_found unless @slide

        # 2. Obtener IDs de audios ya vinculados a este slide
        # Usamos media_id (que es el nombre de la columna en tu migración)
        used_media_ids = SlideMedia.where(slide_id: @slide.id).pluck(:media_id)

        # 3. Definir el scope base (Solo audios)
        if current_user.role == 'admin'
          owner_id = @slide.business.owner_id
          media_table = Media.arel_table

          @media = Media.where(media_type: "audio")
                        .where(
                          media_table[:owner_id].eq(owner_id)
                                                .or(media_table[:owner_id].eq(current_user.id))
                        )
        else
          @media = Media.where(owner_id: current_user.id, media_type: "audio")
        end

        # 4. Excluir los audios que ya están en el slide
        @media = @media.where.not(id: used_media_ids) if used_media_ids.any?

        render json: @media.map { |media| MediaSerializer.new(media).as_json }, status: :ok
      end

      # GET /api/v1/media/1
      def show
        render json: MediaSerializer.new(@media).as_json, status: :ok
      end

      # POST /api/v1/media
      def create
        # Get media type from params
        media_type = params[:media_type]
        file_path = params[:file_path]

        # Validate media type
        unless media_type.present? && %w[image video audio].include?(media_type)
          render json: { error: 'Invalid media type. Must be image, video, or audio.' }, status: :bad_request
          return
        end

        # Set owner to current user if not provided
        owner_id = params[:owner_id].present? ? params[:owner_id] : current_user.id

        media = Media.new(media_type: media_type, owner_id: owner_id, file_path: file_path)
        if media.save
          render json: MediaSerializer.new(media).as_json, status: :created
        else
          # Return error
          render json: { errors: format_errors(media) }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/media/1
      def update
        # Get media type from params or use existing one
        media_type = params[:media_type].present? ? params[:media_type] : @media.media_type

        # Validate media type
        unless media_type.present? && %w[image video audio].include?(media_type)
          render json: { error: 'Invalid media type. Must be image, video, or audio.' }, status: :bad_request
          return
        end

        # Update the media record
        if @media.update(media_params)
          render json: MediaSerializer.new(@media).as_json, status: :ok
        else
          render json: { errors: format_errors(@media) }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/media
      def destroy
        if params[:ids].present?
          # Bulk media deletion
          media_ids = params[:ids].map(&:to_i)

          # Scope to media owned by current user if not admin
          if current_user.role == 'admin'
            medias = Media.where(id: media_ids)
          else
            # Get media owned by the current user
            medias = Media.where(id: media_ids)
                         .where(owner_id: current_user.id)
          end

          medias.each do |media|
            self.broadcast_notify_change(media)
          end

          deleted_count = medias.destroy_all.count

          render json: {
            message: "#{deleted_count} media deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No media IDs provided' }, status: :bad_request
        end
      end

      private

      def broadcast_notify_change(media)
        if media.media_type == 'audio'
          on_slide_medias = Device
                              .joins(slide: :slide_medias)
                              .where(slide_medias: { audio_media_id: media.id })
                              .pluck(:device_id).uniq
        else
          on_slide_medias = Device
                              .joins(slide: :slide_medias)
                              .where(slide_medias: { media_id: media.id })
                              .pluck(:device_id).uniq
        end

        on_slide_medias.each do |device_id|
          action_data = {
            type: "ejecute_data_change", # Tipo de acción para que el cliente la interprete
            payload: {
              updated_at: device_id,
              msg: "Slide Media Notify Changes"
            }
          }
          ChangeDevicesActionsChannel.broadcast_to(
            device_id, # El identificador de la aplicación
            action_data
          )
        end
      end
      def notify_changes
        return unless @media&.persisted?
        self.broadcast_notify_change(@media)
      end

      def set_media
        @media = Media.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Media not found' }, status: :not_found
      end

      def media_params
        # Support direct JSON format without nesting
        params.permit(:media_type, :owner_id, :file_path)
      end

      def verify_media_ownership
        return if current_user.role == 'admin'

        # Check if the current user is the owner of the media
        return if @media.owner_id == current_user.id

        # For backward compatibility, check associations
        # Check if the media is associated with any slides that belong to businesses owned by the current user
        slide_count = @media.slides.joins(:business).where(business: { owner_id: current_user.id }).count

        unless slide_count > 0
          render json: { error: 'Unauthorized: You can only access media that you own or that is associated with your businesses' }, status: :forbidden
        end
      end

    end
  end
end