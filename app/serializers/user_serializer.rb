class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      role: @user.role,
      phone: @user.phone,
      enabled: @user.enabled,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end
end