class SlideSerializer
  def initialize(slide)
    @slide = slide
  end

  def as_json
    {
      id: @slide.id,
      name: @slide.name,
      business_id: @slide.business_id,
      created_at: @slide.created_at,
      updated_at: @slide.updated_at
    }
  end
end