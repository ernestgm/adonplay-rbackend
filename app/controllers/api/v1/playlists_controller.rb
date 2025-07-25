module Api
  module V1
    class PlaylistsController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_playlist, only: [:show, :update, :destroy]
      before_action :verify_playlist_ownership, only: [:show, :update, :destroy]
      before_action :verify_slide_and_qr_ownership, only: [:create, :update]
      
      # GET /api/v1/playlists
      def index
        if current_user.role == 'admin'
          @playlists = Playlist.all
        else
          # For owner, get playlists where the slide belongs to a business they own
          @playlists = Playlist.joins(slide: :business)
                              .where(slides: { businesses: { owner_id: current_user.id } })
        end
        
        render json: @playlists.map { |playlist| PlaylistSerializer.new(playlist).as_json }, status: :ok
      end
      
      # GET /api/v1/playlists/1
      def show
        render json: PlaylistSerializer.new(@playlist).as_json, status: :ok
      end
      
      # POST /api/v1/playlists
      def create
        @playlist = Playlist.new(playlist_params)
        
        if @playlist.save
          render json: PlaylistSerializer.new(@playlist).as_json, status: :created
        else
          render json: { errors: format_errors(@playlist) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/playlists/1
      def update
        if @playlist.update(playlist_params)
          render json: PlaylistSerializer.new(@playlist).as_json, status: :ok
        else
          render json: { errors: format_errors(@playlist) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/playlists
      def destroy
        if params[:id]
          # Single playlist deletion
          @playlist.destroy
          render json: { message: 'Playlist deleted successfully' }, status: :ok
        elsif params[:ids].present?
          # Bulk playlist deletion
          playlist_ids = params[:ids].map(&:to_i)
          
          # Scope to playlists owned by current user if not admin
          if current_user.role == 'admin'
            playlists = Playlist.where(id: playlist_ids)
          else
            playlists = Playlist.joins(slide: :business)
                               .where(id: playlist_ids)
                               .where(slides: { businesses: { owner_id: current_user.id } })
          end
          
          deleted_count = playlists.destroy_all.count
          
          render json: { 
            message: "#{deleted_count} playlists deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No playlist IDs provided' }, status: :bad_request
        end
      end
      
      private
      
      def set_playlist
        @playlist = Playlist.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Playlist not found' }, status: :not_found
      end
      
      def playlist_params
        # Support direct JSON format without nesting
        params.permit(:name, :slide_id, :qr_id)
      end
      
      def verify_playlist_ownership
        return if current_user.role == 'admin'
        
        # Check if the playlist's slide belongs to a business owned by the current user
        unless @playlist.slide.business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only access playlists for your own businesses' }, status: :forbidden
        end
      end
      
      def verify_slide_and_qr_ownership
        return if current_user.role == 'admin'
        
        # Verify slide ownership
        slide_id = params[:slide_id]
        if slide_id
          slide = Slide.find_by(id: slide_id)
          unless slide && slide.business.owner_id == current_user.id
            render json: { error: 'Unauthorized: You can only use slides from your own businesses' }, status: :forbidden
            return
          end
        end
        
        # Verify QR ownership if provided
        qr_id = params[:qr_id]
        if qr_id
          qr = Qr.find_by(id: qr_id)
          unless qr && qr.business.owner_id == current_user.id
            render json: { error: 'Unauthorized: You can only use QRs from your own businesses' }, status: :forbidden
            return
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Slide or QR not found' }, status: :not_found
      end
    end
  end
end