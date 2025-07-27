# Instructions for Running the Default Admin User Migration

This document provides instructions on how to run the migration that adds a default admin user to the database.

## Migration Details

A migration has been created to add a default admin user with the following credentials:
- **Email**: ernestgm2006@gmail.com
- **Password**: Admin.2025
- **Name**: Admin
- **Role**: admin

The migration file is located at: `db/migrate/20250724053300_add_default_admin_user.rb`

## Running the Migration

Since this is a Docker-based project, you need to run the migration within the Docker container. Follow these steps:

### 1. Ensure the Docker container is running

```bash
# Navigate to the project root directory (where the docker-compose.yml file is located)
cd /path/to/adonplay-docker

# Check if the containers are running
docker-compose ps

# If not running, start the containers
docker-compose up -d
```

### 2. Run the migration

```bash
# Run the migration inside the Rails container
docker-compose exec rorbackend rails db:migrate
```

### 3. Verify the migration

```bash
# Check the status of the migrations
docker-compose exec rorbackend rails db:migrate:status
```

You should see that the migration `20250724053300_add_default_admin_user` has been run.

### 4. Verify the admin user was created

You can verify that the admin user was created by checking the database:

```bash
# Access the Rails console
docker-compose exec rorbackend rails console

# In the Rails console, check if the admin user exists
User.find_by(email: 'ernestgm2006@gmail.com')
```

If the user was created successfully, you should see the user details in the console output.

## Troubleshooting

If you encounter any issues with the migration, you can try the following:

```bash
# Reset the database (this will drop all tables and recreate them)
docker-compose exec rorbackend rails db:reset

# Or, if you want to drop the database and recreate it from scratch
docker-compose exec rorbackend rails db:drop
docker-compose exec rorbackend rails db:create
docker-compose exec rorbackend rails db:migrate
```

## Reverting the Migration

If you need to revert the migration (remove the default admin user), you can run:

```bash
# Rollback the last migration
docker-compose exec rorbackend rails db:rollback
```

This will execute the `down` method in the migration, which removes the admin user from the database.