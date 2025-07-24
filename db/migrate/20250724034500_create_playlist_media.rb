class CreatePlaylistMedia < ActiveRecord::Migration[7.0]
  def change
    create_table :playlist_media do |t|
      t.references :playlist, null: false, foreign_key: true
      t.references :media, null: false, foreign_key: true
      t.integer :duration, null: false
      t.text :description, null: false
      t.string :text_size, null: false
      t.string :description_position, null: false

      t.timestamps
    end
    
    add_index :playlist_media, [:playlist_id, :media_id], unique: true
  end
end