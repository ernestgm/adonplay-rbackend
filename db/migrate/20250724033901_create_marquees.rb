class CreateMarquees < ActiveRecord::Migration[7.0]
  def change
    create_table :marquees do |t|
      t.string :name, null: false
      t.text :message, null: false
      t.string :background_color, null: false
      t.string :text_color, null: false
      t.references :business, null: false, foreign_key: true

      t.timestamps
    end
  end
end