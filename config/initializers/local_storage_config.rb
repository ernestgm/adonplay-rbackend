# Local Storage Configuration
Rails.application.config.local_storage = {
  # Base directory for storing files
  base_dir: ENV['LOCAL_STORAGE_BASE_DIR'] || Rails.root.join('public', 'uploads').to_s,
  # Map Rails environment to 'desa' or 'prod'
  environment: Rails.env.production? ? 'prod' : 'desa'
}

# Helper module for local file storage
module LocalStorageHelper
  def self.upload_file(local_file_path, remote_file_path)
    begin
      # Get the base directory from configuration
      base_dir = Rails.application.config.local_storage[:base_dir]
      
      # Combine base directory with remote file path
      full_path = File.join(base_dir, remote_file_path)
      
      # Create directory structure if it doesn't exist
      dir_path = File.dirname(full_path)
      FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
      
      # Copy the file to the destination
      FileUtils.cp(local_file_path, full_path)
      
      # Return the relative path (for URL generation)
      return remote_file_path
    rescue => e
      Rails.logger.error("Failed to upload file to local storage: #{e.message}")
      raise "Local Storage Error: #{e.message}"
    end
  end
  
  def self.delete_file(remote_file_path)
    begin
      # Get the base directory from configuration
      base_dir = Rails.application.config.local_storage[:base_dir]
      
      # Combine base directory with remote file path
      full_path = File.join(base_dir, remote_file_path)
      
      # Delete the file if it exists
      File.delete(full_path) if File.exist?(full_path)
    rescue => e
      Rails.logger.error("Failed to delete file from local storage: #{e.message}")
      raise "Local Storage Error: #{e.message}"
    end
  end
  
  # Helper method to get the URL for a file
  def self.file_url(remote_file_path)
    # Convert the file path to a URL
    # This assumes the base_dir is under public and accessible via web
    "/uploads/#{remote_file_path}"
  end
end