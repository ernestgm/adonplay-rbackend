class ChangeUserActionsChannel < ApplicationCable::Channel
  def subscribed
    @device_id = self.current_device_id
    reject unless @device_id.present?
    stream_for @device_id
  end
end
