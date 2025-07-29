module Api
  module V1
    class MediaController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_media, only: [:show, :update]
      before_action :verify_media_ownership, only: [:show, :update]
      
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
        specific_slide_id = params[:slide_id] # O de donde obtengas el ID del slide

        if current_user.role == 'admin'
          media_ids_already_used_by_slide = SlideMedia.where(slide_id: specific_slide_id).pluck(:media_id).uniq
          @media = Media
                     .where.not(media_type: "audio")
                     .where.not(id: media_ids_already_used_by_slide)
        else
          media_ids_already_used_by_slide = SlideMedia.where(slide_id: specific_slide_id).pluck(:media_id).uniq
          @media = Media.where(owner_id: current_user.id)
                        .where.not(media_type: "audio")
                        .where.not(id: media_ids_already_used_by_slide)
        end

        # Filter by media type if provided
        if params[:media_type].present?
          @media = @media.where(media_type: params[:media_type])
        end

        render json: @media.map { |media| MediaSerializer.new(media).as_json }, status: :ok
      end

      # GET /api/v1/all_audio_excepted/:slide_id
      def all_audio_excepted
        specific_slide_id = params[:slide_id] # O de donde obtengas el ID del slide
        media_ids_already_used_by_slide = SlideMedia.where(slide_id: specific_slide_id).pluck(:audio_media_id).uniq

        if current_user.role == 'admin'
          @media = Media
                     .where(media_type: "audio")
                     .where.not(id: media_ids_already_used_by_slide)
        else
          @media = Media.where(owner_id: current_user.id)
                        .where(media_type: "audio")
                        .where.not(id: media_ids_already_used_by_slide)
        end

        # Filter by media type if provided
        if params[:media_type].present?
          @media = @media.where(media_type: params[:media_type])
        end

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
    
        # Validate media type
        unless media_type.present? && %w[image video audio].include?(media_type)
          render json: { error: 'Invalid media type. Must be image, video, or audio.' }, status: :bad_request
          return
        end
    
        # Set owner to current user if not provided
        owner_id = params[:owner_id].present? ? params[:owner_id] : current_user.id

        # Handle file uploads
        if media_type == 'image' || media_type == 'audio' && params[:file].present?
          files = params[:file].values

          if !files.is_a?(Array)
            render json: { error: 'Files must be array.' }, status: :bad_request
            return
          end

          # For video, only allow a single file
          if media_type == 'video' && files.length > 1
            render json: { error: 'Only one file can be uploaded for video media type.' }, status: :bad_request
            return
          end
      
          # Process each file
          created_media = []
      
          files.each do |file|
            # Create a new media record
            media = Media.new(media_type: media_type, owner_id: owner_id)
        
            # Generate a unique filename
            filename = "#{SecureRandom.uuid}_#{file.original_filename}"
        
            # Create a temporary file
            temp_file_path = Rails.root.join('tmp', filename)
            File.open(temp_file_path, 'wb') do |f|
              f.write(file.read)
            end
        
            # Define the remote path for SFTP
            remote_path = "#{ENVIRONMENT}/medias/user_#{owner_id}/#{media_type.pluralize}/#{filename}"
        
            # Upload the file to local storage
            begin
              LocalStorageHelper.upload_file(temp_file_path, remote_path)
          
              # Set the file path in the media record
              media.file_path = remote_path
          
              # Save the media record
              if media.save
                created_media << media
              else
                # Clean up temporary file
                File.delete(temp_file_path) if File.exist?(temp_file_path)
            
                # Return error
                render json: { errors: format_errors(media) }, status: :unprocessable_entity
                return
              end
            rescue => e
              # Clean up temporary file
              File.delete(temp_file_path) if File.exist?(temp_file_path)
          
              # Return error
              render json: { error: "Failed to upload file: #{e.message}" }, status: :internal_server_error
              return
            ensure
              # Clean up temporary file
              File.delete(temp_file_path) if File.exist?(temp_file_path)
            end
          end
      
          # Return the created media
          if created_media.length == 1
            render json: MediaSerializer.new(created_media.first).as_json, status: :created
          else
            render json: created_media.map { |media| MediaSerializer.new(media).as_json }, status: :created
          end
        elsif params[:file].present?
          # Handle single file upload for backward compatibility
          file = params[:file]
      
          # Create a new media record
          media = Media.new(media_type: media_type, owner_id: owner_id)
      
          # Generate a unique filename
          filename = "#{SecureRandom.uuid}_#{file.original_filename}"
      
          # Create a temporary file
          temp_file_path = Rails.root.join('tmp', filename)
          File.open(temp_file_path, 'wb') do |f|
            f.write(file.read)
          end
      
          # Define the remote path for local storage
          remote_path = "#{ENVIRONMENT}/medias/user_#{owner_id}/#{media_type.pluralize}/#{filename}"
      
          # Upload the file to local storage
          begin
            LocalStorageHelper.upload_file(temp_file_path, remote_path)
        
            # Set the file path in the media record
            media.file_path = remote_path
        
            # Save the media record
            if media.save
              render json: MediaSerializer.new(media).as_json, status: :created
            else
              # Clean up temporary file
              File.delete(temp_file_path) if File.exist?(temp_file_path)
          
              # Return error
              render json: { errors: format_errors(media) }, status: :unprocessable_entity
            end
          rescue => e
            # Clean up temporary file
            File.delete(temp_file_path) if File.exist?(temp_file_path)
        
            # Return error
            render json: { error: "Failed to upload file: #{e.message}" }, status: :internal_server_error
          ensure
            # Clean up temporary file
            File.delete(temp_file_path) if File.exist?(temp_file_path)
          end
        else
          render json: { error: 'No file provided.' }, status: :bad_request
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
    
        # Handle file upload if provided
        if params[:file].present?
          # Delete old file from local storage if it exists
          if @media.file_path.present?
            begin
              LocalStorageHelper.delete_file(@media.file_path)
            rescue => e
              Rails.logger.error("Failed to delete old file: #{e.message}")
              # Continue with the update even if the delete fails
            end
          end
      
          # Generate a unique filename
          filename = "#{SecureRandom.uuid}_#{params[:file].original_filename}"
      
          # Create a temporary file
          temp_file_path = Rails.root.join('tmp', filename)
          File.open(temp_file_path, 'wb') do |f|
            f.write(params[:file].read)
          end
      
          # Define the remote path for local storage
          remote_path = "#{ENVIRONMENT}/medias/user_#{@media.owner_id}/#{media_type.pluralize}/#{filename}"
      
          # Upload the file to local storage
          begin
            LocalStorageHelper.upload_file(temp_file_path, remote_path)
        
            # Set the file path in the media record
            params[:file_path] = remote_path
          rescue => e
            # Clean up temporary file
            File.delete(temp_file_path) if File.exist?(temp_file_path)
        
            # Return error
            render json: { error: "Failed to upload file: #{e.message}" }, status: :internal_server_error
            return
          ensure
            # Clean up temporary file
            File.delete(temp_file_path) if File.exist?(temp_file_path)
          end
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
            media = Media.where(id: media_ids)
          else
            # Get media owned by the current user
            media = Media.where(id: media_ids)
                        .where(owner_id: current_user.id)
          end
      
          # Delete files from local storage for each media
          media.each do |m|
            if m.file_path.present?
              begin
                LocalStorageHelper.delete_file(m.file_path)
              rescue => e
                Rails.logger.error("Failed to delete file from local storage: #{e.message}")
                # Continue with the deletion even if the local storage delete fails
              end
            end
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