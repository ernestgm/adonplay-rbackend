class AddFieldsToSlideMedia < ActiveRecord::Migration[7.0]
  def change
    add_column :slide_media, :order, :integer, null: false, default: 0
    add_column :slide_media, :duration, :integer, null: false, default: 5
    add_reference :slide_media, :audio_media, foreign_key: { to_table: :media }, null: true
    add_reference :slide_media, :qr, foreign_key: true, null: true
    add_column :slide_media, :description, :text
    add_column :slide_media, :text_size, :string
    add_column :slide_media, :description_position, :string
    
    # Add an index on order for faster sorting
    add_index :slide_media, [:slide_id, :order]
  end
end