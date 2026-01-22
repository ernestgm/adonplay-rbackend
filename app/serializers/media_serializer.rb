class MediaSerializer
  def initialize(media)
    @media = media
  end

  def as_json
    {
      id: @media.id,
      media_type: @media.media_type,
      file_path: @media.file_path,
      owner_id: @media.owner_id,
      owner: @media.owner ? UserSerializer.new(@media.owner).as_json : nil,
      is_editable: @media.is_editable,
      json_path: @media.json_path,
      created_at: @media.created_at,
      updated_at: @media.updated_at
    }
  end
end