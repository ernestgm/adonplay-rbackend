class RemoveBusinessIdFromMedia < ActiveRecord::Migration[8.0]
  def up
    # Remove foreign key first to avoid constraint issues
    remove_foreign_key :media, :businesses if foreign_key_exists?(:media, :businesses)
    
    # Remove the column
    remove_column :media, :business_id
  end

  def down
    # Add the column back
    add_reference :media, :business, foreign_key: true
  end
  
  private
  
  def foreign_key_exists?(table, reference)
    foreign_keys = ActiveRecord::Base.connection.foreign_keys(table.to_s)
    foreign_keys.any? { |fk| fk.to_table.to_s == reference.to_s }
  rescue
    false
  end
end