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
      marquee_id: @device.marquee_id,
      slide_id: @device.slide_id,
      created_at: @device.created_at,
      updated_at: @device.updated_at
    }
  end
end