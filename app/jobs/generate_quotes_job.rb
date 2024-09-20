class GenerateQuotesJob < ApplicationJob
  queue_as :default

  def perform
    # Generate price
    previous_quote = Quote.order(created: :desc).first
    previous_price = previous_quote&.price || 50.0  # Default starting price

    # Generate new price with some randomness but based on previous price
    price_change_percent = rand(-2.0..2.0)  # Random percent change between -2% and 2%
    new_price = (previous_price * (1 + price_change_percent / 100)).round(2)

    # Ensure price doesn't go below 1
    new_price = [ new_price, 1.0 ].max

    # Random spikes
    if rand(100) < 4  # 4% chance of a spike
      spike_direction = rand(2) == 0 ? 1 : -1  # Randomly choose up or down
      spike_magnitude = rand(5.0..40.0)  # Random spike between 5% and 40%
      new_price = (previous_price * (1 + spike_direction * spike_magnitude / 100)).round(2)
    end

    # Insert into database and broadcast to client
    quote = Quote.create!(price: new_price, created: Time.current)
    ActionCable.server.broadcast("PriceChannel", { price: quote.price, created: quote.created })
    puts "Generated quote: #{quote.price}!"
  end
end
