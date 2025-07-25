class AddDescriptionPositioAndTextSizeToSlides < ActiveRecord::Migration[8.0]
  def change
    add_column :slides, :description_position, :string
    add_column :slides, :text_size, :string
  end
end
