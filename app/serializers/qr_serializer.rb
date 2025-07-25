class QrSerializer
  def initialize(qr)
    @qr = qr
  end

  def as_json
    {
      id: @qr.id,
      name: @qr.name,
      info: @qr.info,
      position: @qr.position,
      business_id: @qr.business_id,
      created_at: @qr.created_at,
      updated_at: @qr.updated_at
    }
  end
end