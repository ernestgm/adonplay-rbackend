class RenameTextSizeToDescriptionSizeInSlides < ActiveRecord::Migration[8.0]
  def change
    rename_column :slides, :text_size, :description_size
  end
end
