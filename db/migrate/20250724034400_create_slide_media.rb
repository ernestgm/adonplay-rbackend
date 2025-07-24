class CreateSlideMedia < ActiveRecord::Migration[7.0]
  def change
    create_table :slide_media do |t|
      t.references :slide, null: false, foreign_key: true
      t.references :media, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :slide_media, [:slide_id, :media_id], unique: true
  end
end