# Usa una imagen base oficial de Ruby.
FROM ruby:3.2.8

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# --- INSTALACIÓN DE DEPENDENCIAS DEL SISTEMA OPERATIVO (CAPAS SEPARADAS) ---

# 1. Actualizar el índice de paquetes y el sistema base
# El && \ significa que si falla la primera, no continúa.
RUN apt-get update -qq && \
    apt-get upgrade -y

# 2. Instalar herramientas base y bibliotecas principales
# libvips es un paquete pesado y a veces problemático.
RUN apt-get install --no-install-recommends -y \
    curl \
    default-mysql-client \
    libjemalloc2 \
    libvips

# 3. Instalar herramientas de compilación y headers de desarrollo (para gems nativas)
# Esto incluye las dependencias para PostgreSQL (libpq-dev) y MySQL.
RUN apt-get install --no-install-recommends -y \
    build-essential \
    default-libmysqlclient-dev \
    git \
    libyaml-dev \
    pkg-config \
    libpq-dev

# 4. Instalar Node.js y Yarn
# A veces, la versión de Node.js en los repositorios predeterminados puede ser vieja o causar problemas.
# Si esta línea falla, deberías considerar instalar Node.js a través de NodeSource.
RUN apt-get install -y \
    nodejs \
    npm \
    yarn

# 5. Limpieza para reducir el tamaño de la imagen.
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# ---------------------------------------------------------------------------

# Copia el Gemfile y Gemfile.lock primero para aprovechar el cache de Docker.
COPY Gemfile Gemfile.lock ./

# Instala las gems usando Bundler.
RUN bundle install --jobs $(nproc)

# Copia el resto de tu aplicación.
COPY . .

COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# Usa el script de entrada
RUN sed -i 's/\r$//' ./entrypoint.sh
ENTRYPOINT ["sh", "./entrypoint.sh"]
EXPOSE 9000

# Comando por defecto para iniciar la aplicación.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "9000"]