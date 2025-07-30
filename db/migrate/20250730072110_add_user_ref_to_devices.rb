class AddUserRefToDevices < ActiveRecord::Migration[8.0]
  def change
    add_reference :devices, :users, null: true, foreign_key: true
  end
end
