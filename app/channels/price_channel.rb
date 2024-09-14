class PriceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "PriceChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
