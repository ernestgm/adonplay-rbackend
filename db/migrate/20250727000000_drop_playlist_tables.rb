class DropPlaylistTables < ActiveRecord::Migration[8.0]
  def up
    # Remove foreign keys first to avoid constraint issues
    remove_foreign_key :playlist_media, :playlists
    remove_foreign_key :playlist_media, :media
    remove_foreign_key :playlists, :qrs
    remove_foreign_key :playlists, :slides

    # Drop tables
    drop_table :playlist_media
    drop_table :playlists
  end

  def down
    # Recreate playlists table
    create_table :playlists do |t|
      t.string :name, null: false
      t.references :slide, null: false, foreign_key: true
      t.references :qr, foreign_key: true

      t.timestamps
    end

    # Recreate playlist_media table
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