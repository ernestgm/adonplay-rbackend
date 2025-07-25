class BusinessSerializer
  def initialize(business)
    @business = business
  end

  def as_json
    {
      id: @business.id,
      name: @business.name,
      description: @business.description,
      owner_id: @business.owner_id,
      owner: @business.owner ? UserSerializer.new(@business.owner).as_json : nil,
      created_at: @business.created_at,
      updated_at: @business.updated_at
    }
  end
end