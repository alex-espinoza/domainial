class DropCheckWorker
  include HTTParty
  include Sidekiq::Worker
  base_uri 'http://www.nic.io/go/whois'
  sidekiq_options queue: ENV['DROP_CHECK_AVAILABILITY'],
                  retry: 5,
                  backtrace: 3

  sidekiq_retry_in do |count|
    1
  end

  def perform(domain_id)
    domain = WantedDomain.find(domain_id)

    40.times do
      response = make_http_request(domain)
      page_content = get_page_content(response)
      check_availability(page_content, domain)
    end
  end

  def proxy_list
    [
      ["173.161.0.227", "80"],
      ["166.70.157.58", "80"],
      ["136.0.6.202", "8080"],
      ["12.33.254.195", "3128"],
      ["174.129.204.124", "80"],
      ["198.50.153.118",  "81"],
      ["97.107.129.183",  "80"],
      ["142.54.164.106",  "3721"],
      ["169.50.87.252", "80"],
      ["209.159.148.180", "8888"],
    ]
  end

  def make_http_request(domain)
    random_proxy = proxy_list.sample
    request_options = {timeout: 5, follow_redirects: false, http_proxyaddr: random_proxy[0], http_proxyport: random_proxy[1]}

    response = self.class.get("/#{domain.name_with_tld}", request_options)
  end

  def get_page_content(response)
    Nokogiri::HTML(response)
  end

  def check_availability(page_content, domain)
    domain_available = (page_content.css('table')[0].css('td#bodyfill')[0].css('h2').text == "Domain Information")

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
    status = page_content.css('table')[4].css('tr')[3].css('td')[1].text
    first_registered_date = page_content.css('table')[4].css('tr')[4].css('td')[1].text.to_datetime
    last_updated_date = page_content.css('table')[4].css('tr')[5].css('td')[1].text.to_datetime
    expiry_date = page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ')[0].to_datetime

    DropCheck.create!(status_code: 0, wanted_domain: domain, first_registered_date: first_registered_date, last_updated_date: last_updated_date, expiry_date: expiry_date)
  end
end
