class CreateMedia < ActiveRecord::Migration[7.0]
  def change
    create_table :media do |t|
      t.string :media_type, null: false
      t.string :file_path, null: false

      t.timestamps
    end
  end
end