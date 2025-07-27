# Running Migrations

Since this is a Docker-based project, you need to run the migrations within the Docker container. Here are the steps to run the migrations:

## 1. Build and start the Docker container

```bash
# Navigate to the project root directory (where the docker-compose.yml file is located)
cd /path/to/adonplay-docker

# Build and start the containers
docker-compose build
docker-compose up -d
```

## 2. Run the migrations

```bash
# Run the migrations inside the Rails container
docker-compose exec rorbackend rails db:migrate
```

## 3. Verify the migrations

```bash
# Check the status of the migrations
docker-compose exec rorbackend rails db:migrate:status
```

## 4. Seed the database (optional)

If you want to seed the database with initial data, you can edit the `db/seeds.rb` file and then run:

```bash
docker-compose exec rorbackend rails db:seed
```

## Troubleshooting

If you encounter any issues with the migrations, you can try the following:

```bash
# Reset the database (this will drop all tables and recreate them)
docker-compose exec rorbackend rails db:reset

# Or, if you want to drop the database and recreate it from scratch
docker-compose exec rorbackend rails db:drop
docker-compose exec rorbackend rails db:create
docker-compose exec rorbackend rails db:migrate
```

## Models Created

The following models have been created:

1. User (name, email, role[admin,owner], password_digest) - includes authentication with bcrypt
2. Business (name, description)
3. Slide (name) - belongs to a Business, has many Medias through SlideMedia
4. Playlist (name) - belongs to a Slide, has many Medias through PlaylistMedia
5. Device (name, device_id) - can have a QR, a Marquee, and a Slide
6. Marquee (name, message, background_color, text_color) - belongs to a Business
7. QR (name, info, position) - belongs to a Business
8. Media (media_type[image, video, audio], file_path)
9. SlideMedia - join table for Slide and Media
10. PlaylistMedia - join table for Playlist and Media with additional attributes (duration, description, text_size, description_position)

## Authentication and Authorization

The application includes user authentication using bcrypt and JWT (JSON Web Tokens). The following features have been implemented:

1. User signup and login
2. Password encryption using bcrypt
3. Token-based authentication using JWT
4. Role-based authorization (admin and owner roles)
5. CRUD operations for users with appropriate authorization

For detailed information on how to use the API endpoints, please refer to the `API_DOCUMENTATION.md` file.