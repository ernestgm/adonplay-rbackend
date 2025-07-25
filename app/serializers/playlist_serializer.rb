class PlaylistSerializer
  def initialize(playlist)
    @playlist = playlist
  end

  def as_json
    {
      id: @playlist.id,
      name: @playlist.name,
      slide_id: @playlist.slide_id,
      qr_id: @playlist.qr_id,
      created_at: @playlist.created_at,
      updated_at: @playlist.updated_at
    }
  end
end