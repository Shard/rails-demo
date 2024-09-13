#!/usr/bin/env ruby

namespace :jobs do
  desc "Run the stock price generator job every second"
  task run_price_generator: :environment do
    loop do
      GenerateQuotesJob.perform_later
      sleep 1
    end
  end
end
