class WantedDomainCheckWorker
  include HTTParty
  include Sidekiq::Worker
  base_uri 'http://www.nic.io/go/whois'
  sidekiq_options queue: ENV['WANTED_DOMAIN_CHECK_AVAILABILITY'],
                  retry: 5,
                  backtrace: 3

  sidekiq_retry_in do |count|
    90
  end

  def perform(domain_id)
    domain = WantedDomain.find(domain_id)

    response = make_http_request(domain)
    page_content = get_page_content(response)
    check_availability(page_content, domain)
  end

  def proxy_list
    [
      ["166.70.157.58", "80"],
      ["74.202.77.211", "80"],
      ["45.32.214.48",  "808"],
      ["104.236.51.165",  "8080"],
      ["97.107.129.183",  "80"],
      ["97.77.104.22",  "80"],
      ["52.37.174.68",  "80"],
      ["104.236.54.196",  "8080"],
    ]
  end

  def make_http_request(domain)
    random_proxy = proxy_list.sample
    request_options = {timeout: 15, follow_redirects: false, http_proxyaddr: random_proxy[0], http_proxyport: random_proxy[1]}

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
    domain.update(checked?: 1,
                  status: 'Available',
                  status_code: 1,
                  backorder_status: 0)
  end

  def save_as_not_available(page_content, domain)
    status = page_content.css('table')[4].css('tr')[3].css('td')[1].text

    if status == 'Reserved Auction'
      first_registered_date = nil
      last_updated_date = nil
      expiry_date = nil
      grace_period_ends_date = nil
      backorder = nil
      backorder_status = 0
      owner_name = nil
      organization_name = nil
    else
      first_registered_date = page_content.css('table')[4].css('tr')[4].css('td')[1].text.to_datetime
      last_updated_date = page_content.css('table')[4].css('tr')[5].css('td')[1].text.to_datetime
      expiry_date = page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ')[0].to_datetime
      grace_period_ends_date = page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ').last(2).join(' ').to_datetime
      backorder = page_content.css('table')[4].css('tr')[7].css('td')[1].text.split(' ')[0]
      backorder_status = (backorder == "Available" ? 0 : 1)
      owner_name = page_content.css('table')[4].css('tr')[10].css('td')[1]&.text
      organization_name = page_content.css('table')[4].css('tr')[11].css('td')[1]&.text
    end

    domain.update(checked?: 1,
                  status: status,
                  status_code: 0,
                  first_registered_date: first_registered_date,
                  last_updated_date: last_updated_date,
                  expiry_date: expiry_date,
                  grace_period_ends_date: grace_period_ends_date,
                  backorder: backorder,
                  backorder_status: backorder_status,
                  owner_name: owner_name,
                  organization_name: organization_name)
  end
end
