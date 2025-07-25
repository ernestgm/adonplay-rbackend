module Api
  module V1
    class MediaController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_media, only: [:show, :update, :destroy]
      before_action :verify_media_ownership, only: [:show, :update, :destroy]
      
      # GET /api/v1/media
      def index
        if current_user.role == 'admin'
          @media = Media.all
        else
          # For owner, get media associated with slides that belong to businesses they own
          @media = Media.joins(slides: :business)
                       .where(slides: { businesses: { owner_id: current_user.id } })
                       .distinct
        end
        
        render json: @media.map { |media| MediaSerializer.new(media).as_json }, status: :ok
      end
      
      # GET /api/v1/media/1
      def show
        render json: MediaSerializer.new(@media).as_json, status: :ok
      end
      
      # POST /api/v1/media
      def create
        @media = Media.new(media_params)
        
        if @media.save
          render json: MediaSerializer.new(@media).as_json, status: :created
        else
          render json: { errors: format_errors(@media) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/media/1
      def update
        if @media.update(media_params)
          render json: MediaSerializer.new(@media).as_json, status: :ok
        else
          render json: { errors: format_errors(@media) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/media
      def destroy
        if params[:id]
          # Single media deletion
          @media.destroy
          render json: { message: 'Media deleted successfully' }, status: :ok
        elsif params[:ids].present?
          # Bulk media deletion
          media_ids = params[:ids].map(&:to_i)
          
          # Scope to media owned by current user if not admin
          if current_user.role == 'admin'
            media = Media.where(id: media_ids)
          else
            # Get media associated with slides that belong to businesses owned by the current user
            media = Media.joins(slides: :business)
                        .where(id: media_ids)
                        .where(slides: { businesses: { owner_id: current_user.id } })
                        .distinct
          end
          
          deleted_count = media.destroy_all.count
          
          render json: { 
            message: "#{deleted_count} media deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No media IDs provided' }, status: :bad_request
        end
      end
      
      private
      
      def set_media
        @media = Media.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Media not found' }, status: :not_found
      end
      
      def media_params
        # Support direct JSON format without nesting
        params.permit(:media_type, :file_path)
      end
      
      def verify_media_ownership
        return if current_user.role == 'admin'
        
        # Check if the media is associated with any slides that belong to businesses owned by the current user
        slide_count = @media.slides.joins(:business).where(business: { owner_id: current_user.id }).count
        
        # Check if the media is associated with any playlists that belong to slides that belong to businesses owned by the current user
        playlist_count = @media.playlists.joins(slide: :business).where(slides: { businesses: { owner_id: current_user.id } }).count
        
        unless slide_count > 0 || playlist_count > 0
          render json: { error: 'Unauthorized: You can only access media associated with your own businesses' }, status: :forbidden
        end
      end
    end
  end
end