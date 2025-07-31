class DevicesVerifyCodes < ApplicationRecord
  # Validations
  validates :code, presence: true
  validates :device_id, presence: true, uniqueness: true

  def ==
    # code here
  end
end