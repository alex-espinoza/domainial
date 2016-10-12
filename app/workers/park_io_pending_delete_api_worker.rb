class ParkIOPendingDeleteAPIWorker
  include HTTParty

  def initialize
    @tlds = ['io', 'to']
  end

  def perform
    @tlds.each do |tld|
      response = make_api_request(tld)
      save_all_auctions(response)
    end
  end

  def make_api_request(tld)
    self.class.get("https://app.park.io/domains/index/#{tld}.json?limit=9999")
  end

  def save_all_auctions(response)
    response['domains'].each do |domain|
      domain_array = domain['name'].split('.')
      wanted_domain = WantedDomain.new(name: domain_array[0], tld: domain_array[1])

      if wanted_domain.valid? && wanted_domain.save
        WantedDomainCheckEnqueuer.queue(wanted_domain.tld, wanted_domain.id)
      end
    end
  end
end
