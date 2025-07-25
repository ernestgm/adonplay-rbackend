class AddPhoneAndEnabledToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :enabled, :boolean, default: true
  end
end