# 1. Usa la versión más reciente y estable de Ruby (3.4.8).
# Se recomienda usar '-slim' para reducir el tamaño de la imagen significativamente.
FROM ruby:3.4.8-slim

# 2. Establece el directorio de trabajo.
WORKDIR /app

# 3. Instalación de dependencias del sistema optimizada.
# Combinamos los pasos en un solo RUN para reducir capas y limpiamos al final.
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    default-libmysqlclient-dev \
    mariadb-client \
    libyaml-dev \
    pkg-config \
    libvips \
    libjemalloc2 \
    nodejs \
    npm && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# 4. Configuración de variables de entorno para rendimiento.
# LD_PRELOAD con libjemalloc reduce drásticamente el consumo de RAM en aplicaciones Rails.
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# 5. Copia de Gemfile y Gemfile.lock.
COPY Gemfile Gemfile.lock ./

# 6. Instalación de gems.
# Usamos 'bundle install' optimizado para contenedores.
RUN bundle install --jobs "$(nproc)" && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# 7. Copia el resto de la aplicación.
COPY . .

# 8. Preparación del entrypoint.
COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# 9. Configuración final.
ENTRYPOINT ["./entrypoint.sh"]
EXPOSE 9000

# Comando para iniciar Rails.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "9000"]