class SlideMediaSerializer
  def initialize(slide_media)
    @slide_media = slide_media
  end

  def as_json
    {
      id: @slide_media.id,
      slide_id: @slide_media.slide_id,
      slide: @slide_media.slide ? SlideSerializer.new(@slide_media.slide).as_json : nil,
      media_id: @slide_media.media_id,
      media: @slide_media.media ? MediaSerializer.new(@slide_media.media).as_json : nil,
      order: @slide_media.order,
      duration: @slide_media.duration,
      audio_media_id: @slide_media.audio_media_id,
      audio_media: @slide_media.audio_media ? MediaSerializer.new(@slide_media.audio_media).as_json : nil,
      qr_id: @slide_media.qr_id,
      qr: @slide_media.qr ? QrSerializer.new(@slide_media.qr).as_json : nil,
      description: @slide_media.description,
      text_size: @slide_media.text_size,
      description_position: @slide_media.description_position,
      created_at: @slide_media.created_at,
      updated_at: @slide_media.updated_at
    }
  end
end