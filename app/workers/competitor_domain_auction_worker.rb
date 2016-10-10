class CompetitorDomainAuctionWorker
  include Sidekiq::Worker
  sidekiq_options queue: ENV['PARK_IO_QUEUE'],
                  retry: 5,
                  backtrace: 3

  sidekiq_retry_in do |count|
    10
  end

  def perform(auction, source)
    domain_array = auction['name'].split('.')

    competitor_domain = CompetitorDomain.where(name: domain_array[0],
                                               tld: "#{domain_array[1]}",
                                               source: source,
                                               active: 1).first

    if competitor_domain
      competitor_domain.update_attributes!(number_of_bids: auction['num_bids'].to_i,
                                           price: auction['price'].to_i,
                                           auction_end_date: DateTime.strptime(auction['close_date'], '%Y-%d-%m'),
                                           auction_start_date: DateTime.strptime(auction['created'], '%Y-%d-%m'))
    else
      CompetitorDomain.create(name: domain_array[0],
                              tld: "#{domain_array[1]}",
                              number_of_bids: auction['num_bids'].to_i,
                              price: auction['price'].to_i,
                              auction_end_date: DateTime.strptime(auction['close_date'], '%Y-%d-%m'),
                              auction_start_date: DateTime.strptime(auction['created'], '%Y-%d-%m'),
                              active: 1,
                              source: source)
    end
  end
end
