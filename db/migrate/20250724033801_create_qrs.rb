class CreateQrs < ActiveRecord::Migration[7.0]
  def change
    create_table :qrs do |t|
      t.string :name, null: false
      t.text :info, null: false
      t.string :position, null: false
      t.references :business, null: false, foreign_key: true

      t.timestamps
    end
  end
end