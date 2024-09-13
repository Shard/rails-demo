class QuotesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "quotes_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
