class MediaSerializer
  def initialize(media)
    @media = media
  end

  def as_json
    {
      id: @media.id,
      media_type: @media.media_type,
      file_path: @media.file_path,
      created_at: @media.created_at,
      updated_at: @media.updated_at
    }
  end
end