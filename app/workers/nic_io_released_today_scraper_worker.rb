class NicIOReleasedTodayScraperWorker
  def initialize
    @expired_domain_txt_url = 'http://www.nic.io/released/today.txt'
    @agent = Mechanize.new
    @txt_filename = nil
  end

  def perform
    save_expired_domains_text_file
    parse_text_file
    delete_file
  end

  def save_expired_domains_text_file
    file = @agent.get(@expired_domain_txt_url)
    @txt_filename = file.save("tmp/txt/#{file.filename}")
  end

  def parse_text_file
    # do not load whole file into memory, read line by line
    File.foreach(@txt_filename) do |line|
      domain_array = line.strip.split('.')

      if domain_array[1] == 'io'
        save_domain_as_wanted(domain_array)
      end
    end
  end

  def save_domain_as_wanted(domain_array)
    wanted_domain = WantedDomain.new(name: domain_array[0], tld: domain_array[1])

    if wanted_domain.valid? && wanted_domain.save
      WantedDomainCheckEnqueuer.queue(wanted_domain.tld, wanted_domain.id)
    end
  end

  def delete_file
    File.delete(@txt_filename)
  end
end
