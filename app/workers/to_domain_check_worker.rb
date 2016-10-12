class TODomainCheckWorker
  include HTTParty
  include Sidekiq::Worker
  base_uri 'https://www.tonic.to/whois?'
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
    domain.update(checked?: 1,
                   status: 'Available',
                   status_code: 1,
                   backorder: nil,
                   backorder_status: 0,
                   first_registered_date: nil,
                   last_updated_date: nil,
                   expiry_date: nil,
                   grace_period_ends_date: nil,
                   owner_name: nil,
                   organization_name: nil)
  end

  def save_as_not_available(page_content, domain)
    domain_info_array = page_content.css('pre')[0].text.split("\n")

    first_registered_date = domain_info_array[2].split(':', 2)[1].strip.to_datetime
    last_updated_date = domain_info_array[3].split(':', 2)[1].strip.to_datetime
    expiry_date = domain_info_array[4].split(':', 2)[1].strip.to_datetime
    grace_period_ends_date = expiry_date + 1.month
    owner_name = domain_info_array[6].split(':', 2)[1].strip

    domain.update(checked?: 1,
                   status: 'Not Available',
                   status_code: 0,
                   first_registered_date: first_registered_date,
                   last_updated_date: last_updated_date,
                   expiry_date: expiry_date,
                   grace_period_ends_date: grace_period_ends_date,
                   backorder: nil,
                   backorder_status: 0,
                   owner_name: owner_name,
                   organization_name: nil)
  end
end
