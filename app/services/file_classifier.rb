class FileClassifier
  def self.classify(filename)
    extension = File.extname(filename.to_s).delete('.').downcase

    if image_extensions.include?(extension)
      "image"
    elsif video_extensions.include?(extension)
      "video"
    elsif audio_extensions.include?(extension)
      "audio"
    else
      "unknow"
    end
  end

  private
  def self.image_extensions
    %w[jpg jpeg png gif bmp tiff tif webp heic heif svg raw]
  end

  def self.video_extensions
    %w[mp4 avi mov qt wmv flv mkv webm mpg mpeg 3gp 3g2]
  end

  def self.audio_extensions
    %w[mp3 wav flac aac ogg oga wma m4a aiff aif]
  end
end