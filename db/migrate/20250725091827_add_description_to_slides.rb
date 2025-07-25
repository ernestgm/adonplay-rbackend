class AddDescriptionToSlides < ActiveRecord::Migration[8.0]
  def change
    add_column :slides, :description, :string
  end
end
