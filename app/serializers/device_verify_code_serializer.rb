class DeviceVerifyCodeSerializer
  def initialize(device_verify_code)
    @device_verify_code = device_verify_code
  end

  def as_json
    {
      id: @device_verify_code.id,
      device_id: @device_verify_code.device_id,
      code: @device_verify_code.code,
      registered: @device_verify_code.registered,
      created_at: @device_verify_code.created_at,
      updated_at: @device_verify_code.updated_at
    }
  end
end