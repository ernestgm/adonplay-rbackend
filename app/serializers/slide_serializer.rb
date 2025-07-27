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
      description_size: @slide.description_size,
      business_id: @slide.business_id,
      business: @slide.business ? BusinessSerializer.new(@slide.business).as_json : nil,
      created_at: @slide.created_at,
      updated_at: @slide.updated_at
    }
  end
end