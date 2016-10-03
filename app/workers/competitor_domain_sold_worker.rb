class CompetitorDomainSoldWorker
  include Sidekiq::Worker
  sidekiq_options queue: ENV['PARK_IO_QUEUE'],
                  retry: 5,
                  backtrace: 3

  sidekiq_retry_in do |count|
    10
  end

  def perform(domain, date, price, source)
    domain_array = domain.split('.')

    competitor_domain = CompetitorDomain.where(name: domain_array[0],
                                               tld: ".#{domain_array[1]}",
                                               source: source,
                                               active: 1).first

    if competitor_domain
      competitor_domain.update_attributes!(sold_date: date.to_datetime,
                                           price: price.to_i,
                                           active: 0,
                                           source: source)
    else
      CompetitorDomain.create!(name: domain_array[0],
                               tld: ".#{domain_array[1]}",
                               sold_date: date.to_datetime,
                               price: price.to_i,
                               active: 0,
                               source: source)
    end
  end
end
