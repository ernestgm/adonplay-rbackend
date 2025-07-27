class CreateSlides < ActiveRecord::Migration[7.0]
  def change
    create_table :slides do |t|
      t.string :name, null: false
      t.references :business, null: false, foreign_key: true

      t.timestamps
    end
  end
end