class WantedDomainCheckWorker
  include HTTParty
  include Shoryuken::Worker
  base_uri 'http://nic.io/go/whois'
  shoryuken_options queue: ENV['WANTED_DOMAIN_CHECK_AVAILABILITY'],
                    auto_delete: true,
                    body_parser: :json,
                    retry_intervals: 3600

  def perform(sqs_message, data)
    domain = WantedDomain.find(data['domain_id'])

    response = make_http_request(domain)
    page_content = get_page_content(response)
    check_availability(page_content, domain)
  end

  def make_http_request(domain)
    begin
      response = self.class.get("/#{domain.name_with_tld}")
    rescue HTTParty::Error => e
      error_log_file = ActiveSupport::Logger.new('log/wanted_domain_check_worker.rake.err')
      time = Time.now
      error_text = "[ERROR] - [#{time}] - #{e}"
      error_log_file.info(error_text)
      error_log_file.close
    end
  end

  def get_page_content(response)
    Nokogiri::HTML(response)
  end

  def check_availability(page_content, domain)
    domain_available = (page_content.css('table')[0].css('td#bodyfill')[0].css('h3').text == domain.name_with_tld)

    if domain_available
      save_as_available(domain)
    else
      save_as_not_available(page_content, domain)
    end
  end

  def save_as_available(domain)
    domain.update(checked?: 1,
                   status: 'Available',
                   status_code: 1)
  end

  def save_as_not_available(page_content, domain)
    status = page_content.css('table')[4].css('tr')[3].css('td')[1].text
    first_registered_date = page_content.css('table')[4].css('tr')[4].css('td')[1].text.to_datetime
    last_updated_date = page_content.css('table')[4].css('tr')[5].css('td')[1].text.to_datetime
    expiry_date = page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ')[0].to_datetime
    grace_period_ends_date = page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ').last(2).join(' ').to_datetime
    backorder = page_content.css('table')[4].css('tr')[7].css('td')[1].text.split(' ')[0]
    owner_name = page_content.css('table')[4].css('tr')[10].css('td')[1].text
    organization_name = page_content.css('table')[4].css('tr')[11].css('td')[1].text

    domain.update(checked?: 1,
                   status: status,
                   status_code: 0,
                   first_registered_date: first_registered_date,
                   last_updated_date: last_updated_date,
                   expiry_date: expiry_date,
                   grace_period_ends_date: grace_period_ends_date,
                   backorder: backorder,
                   owner_name: owner_name,
                   organization_name: organization_name)
  end
end
