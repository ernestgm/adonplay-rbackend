class LoginCodeSerializer
  def initialize(login_code)
    @login_code = login_code
  end

  def as_json
    {
      id: @login_code.id,
      device_id: @login_code.device_id,
      code: @login_code.code,
      user_id: @login_code.user_id,
      created_at: @login_code.created_at,
      updated_at: @login_code.updated_at
    }
  end
end