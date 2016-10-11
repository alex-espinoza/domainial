class FreshDropPendingDeleteScraperWorker
  include HTTParty

  def initialize
    @json_page = 0
    @total_count = 10
    @count = 0
    @offset = 0
    @endpoint_url = "https://www.freshdrop.com/Search?1=1&me_id=0&page=#{@json_page}&mt_id=0&mf_id=0&sortcol=end_datetime&sortdir=asc&is_force_sort=0&is_noqc=0&origin=&df=DYNADOT%2CEXPIRED_NAME%2CNAMEJET_PRE%2CSNAP_EXP%2CNAME%2CPOOL_DELETE%2CNAMEJET_DELETE%2CSNAP_DELETE%2CPHEENIX_DELETE&qf=&tld=to&domain_exclude%5Bhyphen%5D=1"
    @response = nil
  end

  def perform
    while @count + @offset < @total_count
      @response = make_api_request
      save_domains_as_wanted
      update_count_values
    end
  end

  def make_api_request
    self.class.get(@endpoint_url)
  end

  def update_count_values
    @total_count = @response["total_count"]
    @count = @response["count"]
    @offset = @response["offset"]
    @json_page += 1
    @endpoint_url = "https://www.freshdrop.com/Search?1=1&me_id=0&page=#{@json_page}&mt_id=0&mf_id=0&sortcol=end_datetime&sortdir=asc&is_force_sort=0&is_noqc=0&origin=&df=DYNADOT%2CEXPIRED_NAME%2CNAMEJET_PRE%2CSNAP_EXP%2CNAME%2CPOOL_DELETE%2CNAMEJET_DELETE%2CSNAP_DELETE%2CPHEENIX_DELETE&qf=&tld=to&domain_exclude%5Bhyphen%5D=1"
  end

  def save_domains_as_wanted
    @response["rows"].each do |row|
      domain_array = row[1].split('.')
      wanted_domain = WantedDomain.new(name: domain_array[0], tld: domain_array[1])

      if wanted_domain.valid? && wanted_domain.save
        WantedDomainCheckEnqueuer.queue(wanted_domain.tld, wanted_domain.id)
      end
    end
  end
end
