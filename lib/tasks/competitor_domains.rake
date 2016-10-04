namespace :competitor_domains do
  desc 'Check Park.io for recently sold domains'
  task park_io_check_sold: :environment do
    park = ParkIOSoldCSVWorker.new
    park.perform
  end

  desc 'Check Park.io for auction updates'
  task park_io_check_auctions: :environment do
    park = ParkIOAuctionAPIWorker.new
    park.perform
  end
end
