class QuotesController < ApplicationController
  def index
    @current_price = Quote.order(created: :desc).first&.price || 0
    @historical_prices = Quote.order(created: :desc).limit(30).pluck(:price, :created)
  end

  def buy
    # Implement buy logic here
    redirect_to quotes_path, notice: 'Stock purchased successfully'
  end

  def sell
    # Implement sell logic here
    redirect_to quotes_path, notice: 'Stock sold successfully'
  end
end
