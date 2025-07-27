class CreateDevices < ActiveRecord::Migration[7.0]
  def change
    create_table :devices do |t|
      t.string :name, null: false
      t.string :device_id, null: false
      t.references :qr, foreign_key: true
      t.references :marquee, foreign_key: true
      t.references :slide, foreign_key: true

      t.timestamps
    end
    
    add_index :devices, :device_id, unique: true
  end
end