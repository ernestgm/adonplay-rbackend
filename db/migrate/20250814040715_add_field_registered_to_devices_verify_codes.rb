class AddFieldRegisteredToDevicesVerifyCodes < ActiveRecord::Migration[8.0]
  def change
    add_column :devices_verify_codes, :registered, :boolean, default: false
  end
end
