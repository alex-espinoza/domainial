class TODropCheckWorker
  include HTTParty
  include Sidekiq::Worker
  base_uri 'https://www.tonic.to/whois?'
  sidekiq_options queue: ENV['DROP_CHECK_AVAILABILITY'],
                  retry: 5,
                  backtrace: 3

  sidekiq_retry_in do |count|
    1
  end

  def perform(domain_id)
    domain = WantedDomain.find(domain_id)

    response = make_http_request(domain)
    page_content = get_page_content(response)
    check_availability(page_content, domain)
  end

  def make_http_request(domain)
    random_proxy = WantedDomain::PROXY_LIST.sample
    #request_options = {timeout: 15, follow_redirects: false, http_proxyaddr: random_proxy[0], http_proxyport: random_proxy[1]}
    request_options = {timeout: 15, follow_redirects: false}

    response = self.class.get("#{domain.name_with_tld}", request_options)
  end

  def get_page_content(response)
    Nokogiri::HTML(response)
  end

  def check_availability(page_content, domain)
    domain_available = page_content.css('pre')[0].text.include?('No match')

    if domain_available
      save_as_available(domain)
    else
      save_as_not_available(page_content, domain)
    end
  end

  def save_as_available(domain)
    DropCheck.create!(status_code: 1, wanted_domain: domain)
  end

  def save_as_not_available(page_content, domain)
    domain_info_array = page_content.css('pre')[0].text.split("\n")

    first_registered_date = domain_info_array[2].split(':', 2)[1].strip.to_datetime
    last_updated_date = domain_info_array[3].split(':', 2)[1].strip.to_datetime
    expiry_date = domain_info_array[4].split(':', 2)[1].strip.to_datetime

    DropCheck.create!(status_code: 0, wanted_domain: domain, first_registered_date: first_registered_date, last_updated_date: last_updated_date, expiry_date: expiry_date)
  end
end
