class WantedDomainCheckWorker
  include HTTParty
  base_uri 'http://nic.io/go/whois'

  def initialize(domain)
    @domain = domain
    @domain_name = "/#{@domain.name_with_tld}"
  end

  def check_availability
    begin
      response = self.class.get(@domain_name)
    rescue HTTParty::Error => e
      error_log_file = ActiveSupport::Logger.new('log/wanted_domain_check_worker.rake.err')
      time = Time.now
      error_text = "[ERROR] - [#{time}] - #{error}"
      puts error_text
      error_log_file.info(error_text)
      error_log_file.close
    end

    puts response
  end
end
