# Usa una imagen base oficial de Ruby.
FROM ruby:3.2.8

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Instala dependencias del sistema operativo necesarias.
# Por ejemplo, para nokogiri, pg (PostgreSQL), etc.
# Si tu aplicación usa otras bases de datos como MySQL, necesitarás añadir libmysqlclient-dev.

# Install base packages
RUN apt-get update -qq && apt-get upgrade && \
    apt-get install --no-install-recommends -y curl default-mysql-client libjemalloc2 libvips && \
    apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev git libyaml-dev pkg-config && \
    apt-get install -y build-essential libpq-dev nodejs npm yarn && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copia el Gemfile y Gemfile.lock primero para aprovechar el cache de Docker.
# Si estos archivos no cambian, Docker no reinstalará las gems.
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