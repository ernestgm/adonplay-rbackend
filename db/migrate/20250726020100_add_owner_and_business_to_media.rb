class AddOwnerAndBusinessToMedia < ActiveRecord::Migration[7.0]
  def change
    add_reference :media, :owner, foreign_key: { to_table: :users }, null: true
    add_reference :media, :business, foreign_key: true, null: true
    
    # Add an index on media_type for faster queries
    add_index :media, :media_type
  end
end