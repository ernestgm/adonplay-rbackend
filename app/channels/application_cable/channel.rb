# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def current_device_id
      connection.device_id
    end
  end
end