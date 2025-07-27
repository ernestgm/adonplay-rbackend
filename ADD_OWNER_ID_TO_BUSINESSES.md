# Adding owner_id to Businesses

## Issue Description

The Business model has a relationship with User through `belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'`, but the database schema doesn't have the corresponding `owner_id` column in the businesses table.

## Solution

A new migration has been created to add the `owner_id` field to the businesses table:

```ruby
# db/migrate/20250725043300_add_owner_id_to_businesses.rb
class AddOwnerIdToBusinesses < ActiveRecord::Migration[7.0]
  def change
    add_reference :businesses, :owner, foreign_key: { to_table: :users }, null: false
  end
end
```

This migration adds a foreign key reference to the users table, with the column name `owner_id`. The field is set to `null: false` to ensure that every business has an owner, which matches the validation in the Business model.

## How to Apply the Migration

To apply this migration in your development environment, run:

```bash
rails db:migrate
```

This will update the database schema and generate a new schema.rb file with the changes.

## Potential Issues

Since the `owner_id` field is set to `null: false`, you'll need to ensure that all existing businesses have an owner assigned before running the migration. If you have existing businesses in your database, you might need to modify the migration to allow null values initially, assign owners to all businesses, and then add the not-null constraint:

```ruby
class AddOwnerIdToBusinesses < ActiveRecord::Migration[7.0]
  def up
    # Add the column allowing null values initially
    add_reference :businesses, :owner, foreign_key: { to_table: :users }, null: true
    
    # Assign an owner to all existing businesses (e.g., the first admin user)
    admin_user_id = User.find_by(role: 'admin')&.id
    if admin_user_id
      Business.update_all(owner_id: admin_user_id)
    end
    
    # Add the not-null constraint
    change_column_null :businesses, :owner_id, false
  end
  
  def down
    remove_reference :businesses, :owner
  end
end
```

## Verification

After running the migration, you can verify that the `owner_id` field has been added to the businesses table by checking the schema.rb file or by running:

```bash
rails db:schema:dump
rails runner "puts ActiveRecord::Base.connection.columns('businesses').map(&:name)"
```

This should output a list of columns that includes `owner_id`.

## Related Code

The Business model already has the relationship defined:

```ruby
# app/models/business.rb
class Business < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  # ...
end
```

And the User model has the corresponding relationship:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # Associations
  has_many :businesses, foreign_key: 'owner_id', dependent: :destroy
  # ...
end
```

The controllers are also set up to handle owner-based access control, so no additional changes are needed there.