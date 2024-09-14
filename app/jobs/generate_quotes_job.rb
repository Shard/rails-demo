class GenerateQuotesJob < ApplicationJob
  queue_as :default

  def perform
    price = rand(10.0..100.0).round(2)
    quote = Quote.create!(price: price, created: Time.current)
    ActionCable.server.broadcast("PriceChannel", { price: quote.price, created: quote.created })
    puts "Generated quote: #{quote.price}!"
  end
end
