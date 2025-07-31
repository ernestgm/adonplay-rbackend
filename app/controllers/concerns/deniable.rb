module Deniable
  extend ActiveSupport::Concern

  included do
    before_action :verify_request
    attr_reader :current_device
  end

  def check_device_id!(device_id)
    unless DeviceValidator.is_valid_device_id?(device_id)
      render json: { error: 'Unauthorized: Device Id not valid' }, status: :forbidden
    end
  end

  def check_valid_player!(device_id, code)
    unless DeviceValidator.is_valid_device_id?(device_id)
      render json: { error: 'Unauthorized: Device Id not valid' }, status: :forbidden
    end

    unless DeviceValidator.is_valid_luhn?(code)
      render json: { error: 'Unauthorized: Device Code not valid', code: code }, status: :forbidden
    end
  end

  private

  def verify_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    begin
      decoded = JsonWebToken.decode(token)
      @current_device = DevicesVerifyCodes.find_by(device_id: decoded[:device_id])
    rescue ActiveRecord::RecordNotFound, NoMethodError
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end