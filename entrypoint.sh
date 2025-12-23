#!/usr/bin/env bash
set -e # Salir inmediatamente si un comando falla

# mariadb-admin ping -h adonplay-db -u adonplay -psecret
# Variables de entorno
MYSQL_HOST=${DB_HOST:-mariadb}
MYSQL_USER=${DB_USERNAME:-adonplay}
MYSQL_PASSWORD=${DB_PASSWORD:-secret}
MYSQL_DATABASE=${DB_DATABASE:-adonplay_api_db}

echo "Waiting for MySQL/MariaDB to be ready at $MYSQL_HOST..."

# Cambiamos 'mysqladmin' por 'mariadb-admin'
# Este comando es compatible con servidores MySQL y MariaDB
until mariadb-admin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  >&2 echo "MySQL/MariaDB is unavailable - sleeping"
  sleep 1
done

>&2 echo "MySQL/MariaDB is up - executing command"

# Elimina cualquier archivo PID de un servidor anterior (crucial para Rails)
rm -f /app/tmp/pids/server.pid

# Ejecuta las migraciones de la base de datos
echo "Running database migrations..."
# Agregamos 'db:prepare' que es más seguro: crea la DB si no existe y luego corre migraciones
bundle exec rails db:prepare

# Ejecuta el comando principal del contenedor (el CMD del Dockerfile)
echo "Starting application..."
exec "$@"