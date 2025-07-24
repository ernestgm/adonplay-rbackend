class CreatePlaylists < ActiveRecord::Migration[7.0]
  def change
    create_table :playlists do |t|
      t.string :name, null: false
      t.references :slide, null: false, foreign_key: true
      t.references :qr, foreign_key: true

      t.timestamps
    end
  end
end