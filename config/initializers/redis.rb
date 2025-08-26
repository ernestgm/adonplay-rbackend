# config/initializers/redis.rb

$redis = Redis.new(url: ENV.fetch("REDIS_URL") { "redis://redis:6379/1" })

# Opcionalmente, si usas Sidekiq o similar, puedes configurar un pool de conexiones
# require 'connection_pool'

# $redis_pool = ConnectionPool.new(size: 5, timeout: 5) do
#   Redis.new(url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" })
# end