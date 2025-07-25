class SlideSerializer
  def initialize(slide)
    @slide = slide
  end

  def as_json
    {
      id: @slide.id,
      name: @slide.name,
      description: @slide.description,
      description_position: @slide.description_position,
      text_size: @slide.text_size,
      business_id: @slide.business_id,
      created_at: @slide.created_at,
      updated_at: @slide.updated_at
    }
  end
end