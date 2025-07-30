class DeviceSerializer
  def initialize(device)
    @device = device
  end

  def as_json
    {
      id: @device.id,
      name: @device.name,
      device_id: @device.device_id,
      qr_id: @device.qr_id,
      qr: @device.qr ? QrSerializer.new(@device.qr).as_json : nil,
      marquee_id: @device.marquee_id,
      marquee: @device.marquee ? MarqueeSerializer.new(@device.marquee).as_json : nil,
      slide_id: @device.slide_id,
      slide: @device.slide ? SlideSerializer.new(@device.slide).as_json : nil,
      users_id: @device.users_id,
      user: @device.users ? UserSerializer.new(@device.users).as_json : nil,
      created_at: @device.created_at,
      updated_at: @device.updated_at
    }
  end
end