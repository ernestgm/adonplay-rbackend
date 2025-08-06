class AddFieldPortraitAndAsPresentationToDevice < ActiveRecord::Migration[8.0]
  def change
    add_column :devices, :portrait, :boolean, default: false
    add_column :devices, :as_presentation, :boolean, default: false
  end
end
