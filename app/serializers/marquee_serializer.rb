class MarqueeSerializer
  def initialize(marquee)
    @marquee = marquee
  end

  def as_json
    {
      id: @marquee.id,
      name: @marquee.name,
      message: @marquee.message,
      background_color: @marquee.background_color,
      text_color: @marquee.text_color,
      business_id: @marquee.business_id,
      business: @marquee.business ? BusinessSerializer.new(@marquee.business).as_json : nil,
      created_at: @marquee.created_at,
      updated_at: @marquee.updated_at
    }
  end
end