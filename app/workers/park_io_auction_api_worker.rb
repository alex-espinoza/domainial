class ParkIOAuctionAPIWorker
  include HTTParty

  def initialize
    @endpoint_url = 'https://app.park.io/auctions.json'
  end

  def perform
    response = make_api_request
    save_all_auctions(response)
  end

  def make_api_request
    self.class.get(@endpoint_url)
  end

  def save_all_auctions(response)
    response['auctions'].each do |auction|
      CompetitorDomainUpdaterWorker.perform_async(auction, 'park.io')
    end
  end
end
