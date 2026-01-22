class AddEditableFieldsToMedia < ActiveRecord::Migration[7.0]
  def change
    add_column :media, :is_editable, :boolean, default: false
    add_column :media, :json_path, :string
  end
end
