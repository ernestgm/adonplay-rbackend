#!/bin/bash
set -e # Salir inmediatamente si un comando falla

# Variables de entorno para MySQL (asegúrate de que coincidan con tu docker-compose.yml o tus variables de entorno)
MYSQL_HOST=${DB_HOST:-mysql} # Por defecto 'db' si usas docker-compose
MYSQL_USER=${DB_USER:-adonplay}
MYSQL_PASSWORD=${DB_PASSWORD:-secret} # ¡Cambia esto por tu contraseña real!
MYSQL_DATABASE=${DB_DATABASE:-adonplay_api_db} # Nombre de tu base de datos

echo "Waiting for MySQL to be ready..."
# Esperar a que la base de datos MySQL esté disponible
# El comando 'mysqladmin ping' intentará conectarse y fallará si la DB no está lista
until mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 1
done

>&2 echo "MySQL is up - executing command"

# Elimina cualquier archivo PID de un servidor anterior (crucial para Rails)
rm -f /app/tmp/pids/server.pid

# Ejecuta las migraciones de la base de datos
echo "Running database migrations..."
bundle exec rails db:migrate

# Ejecuta el comando principal del contenedor
echo "Starting application..."
exec "$@"