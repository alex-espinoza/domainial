class WantedDomainCheckWorker
  include HTTParty
  include Shoryuken::Worker
  base_uri 'http://www.nic.io/go/whois'
  shoryuken_options queue: ENV['WANTED_DOMAIN_CHECK_AVAILABILITY'],
                    auto_delete: true,
                    body_parser: :json,
                    retry_intervals: 120,
                    auto_visibility_timeout: true

  def perform(sqs_message, data)
    domain = WantedDomain.find(data['domain_id'])

    begin
      response = make_http_request(domain)
      page_content = get_page_content(response)
      check_availability(page_content, domain)
    raise HTTParty::Error, Net::ReadTimeout, Nokogiri::CSS::SyntaxError, StandardError => e
      puts "!!!"
      puts "#{e.class} - Domain: #{domain.id}"
      puts e.message
      puts e.backtrace[0]
      puts e.backtrace[1]
      puts "!!!"
    end
  end

  def proxy_list
    [
      ["159.203.111.101", "3128"],
      ["166.70.157.58", "80"],
      ["138.68.152.51", "8080"],
      ["209.64.81.18", " 8080"],
      ["209.150.253.82", " 80"],
      ["192.169.174.121", "8088"],
      ["199.116.113.206", "8080"],
      ["162.209.1.221", "8080"],
      ["173.161.0.227", "80"],
      ["97.77.104.22", "80"],
      ["173.161.0.227", "80"],
      ["166.70.157.58", "80"],
      ["74.202.77.224", "80"],
      ["45.32.194.8", "8080"],
      ["52.43.19.20", "80"],
      ["169.50.87.252", "80"],
      ["208.40.165.200", "80"],
      ["45.32.61.250", "3128"],
      ["104.247.206.243", "3128"],
      ["184.75.243.101", "13100"],
      ["45.32.218.222", "808"],
      ["52.30.138.5", "3128"],
      ["45.55.143.243", "3128"],
      ["45.32.212.133", "808"],
      ["69.51.111.14" , "80"],
      ["52.23.236.195", "80"],
      ["69.50.56.73", "8080"],
      ["184.49.233.234", "8080"],
      ["107.170.213.149", "3128"]
    ]
  end

  def make_http_request(domain)
    random_proxy = proxy_list.sample
    request_options = {timeout: 10, http_proxyaddr: random_proxy[0], http_proxyport: random_proxy[1]}

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
                   status_code: 1)
  end

  def save_as_not_available(page_content, domain)
    status = page_content.css('table')[4].css('tr')[3].css('td')[1].text

    if status == 'Reserved Auction'
      first_registered_date = nil
      last_updated_date = nil
      expiry_date = nil
      grace_period_ends_date = nil
      backorder = nil
      owner_name = nil
      organization_name = nil
    else
      first_registered_date = page_content.css('table')[4].css('tr')[4].css('td')[1].text.to_datetime
      last_updated_date = page_content.css('table')[4].css('tr')[5].css('td')[1].text.to_datetime
      expiry_date = page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ')[0].to_datetime
      grace_period_ends_date = page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ').last(2).join(' ').to_datetime
      backorder = page_content.css('table')[4].css('tr')[7].css('td')[1].text.split(' ')[0]
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
                   owner_name: owner_name,
                   organization_name: organization_name)
  end
end
