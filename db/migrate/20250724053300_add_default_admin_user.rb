class AddDefaultAdminUser < ActiveRecord::Migration[8.0]
  def up
    # Check if the admin user already exists
    admin_email = 'ernestgm2006@gmail.com'
    
    # Use execute to check if the user exists to avoid loading the User model
    # which might not be compatible with the migration (especially in older versions)
    user_exists = ActiveRecord::Base.connection.select_value(
      "SELECT COUNT(*) FROM users WHERE email = '#{admin_email}'"
    ).to_i > 0
    
    unless user_exists
      # Need to require bcrypt to use it in the migration
      require 'bcrypt'
      
      # Create the admin user directly using SQL to avoid model dependencies
      password_digest = BCrypt::Password.create('Admin.2025')

      ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO users (name, email, role, created_at, updated_at, password_digest)
        VALUES (
          'Admin', 
          '#{admin_email}', 
          'admin',
          NOW(),
          NOW(),
          '#{password_digest}'
        )
      SQL
      puts 'Default admin user created successfully!'
    else
      puts 'Default admin user already exists, skipping creation.'
    end
  end

  def down
    admin_email = 'ernestgm2006@gmail.com'
    
    # Remove the admin user if needed using SQL
    ActiveRecord::Base.connection.execute(
      "DELETE FROM users WHERE email = '#{admin_email}'"
    )
    puts 'Default admin user removed successfully!'
  end
end