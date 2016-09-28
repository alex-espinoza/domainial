class WantedDomainCheckWorker
  include HTTParty
  base_uri 'http://nic.io/go/whois'

  def initialize(domain)
    @domain = domain
    @domain_name = "/#{@domain.name_with_tld}"
    @response = nil
    @page_content = nil
  end

  def make_http_request
    begin
      @response = self.class.get(@domain_name)
    rescue HTTParty::Error => e
      error_log_file = ActiveSupport::Logger.new('log/wanted_domain_check_worker.rake.err')
      time = Time.now
      error_text = "[ERROR] - [#{time}] - #{error}"
      error_log_file.info(error_text)
      error_log_file.close
    end

    if @response
      check_availability
    end
  end

  def check_availability
    @page_content = Nokogiri::HTML(@response)
    domain_available = @page_content.css('table')[0].css('td#bodyfill')[0].css('h3').text

    if domain_available
      parse_available_response
    else
      parse_unavailable_response
    end
  end

  def parse_available_response
    @domain.update(checked?: 1,
                   status: "Available",
                   status_code: 1)
  end

  def parse_unavailable_response
    status = @page_content.css('table')[4].css('tr')[3].css('td')[1].text
    first_registered_date = @page_content.css('table')[4].css('tr')[4].css('td')[1].text.to_datetime
    last_updated_date = @page_content.css('table')[4].css('tr')[5].css('td')[1].text.to_datetime
    expiry_date = @page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ')[0].to_datetime
    grace_period_ends_date = @page_content.css('table')[4].css('tr')[6].css('td')[1].text.split(' ').last(2).join(' ').to_datetime
    backorder = @page_content.css('table')[4].css('tr')[7].css('td')[1].text.split(' ')[0]
    owner_name = @page_content.css('table')[4].css('tr')[10].css('td')[1].text
    organization_name = @page_content.css('table')[4].css('tr')[11].css('td')[1].text

    @domain.update(checked?: 1,
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
