class ExpiredDomainsPendingDeleteScraperWorker
  def initialize
    @login_url = 'https://www.expireddomains.net/login/'
    @pending_delete_domain_txt_file_url = 'https://member.expireddomains.net/export/pendingdelete/?export=textfile&flast30d=1&ftlds[]=125&flimit=25&fconsephost=1&fsephost=1&o=enddate&r=a'
    @username = 'cyant'
    @password = 'Ildeexpired90'
    @agent = Mechanize.new
    @txt_filename = nil
  end

  def perform
    log_in_to_site
    download_pending_delete_domains_text_file
    parse_text_file
    delete_file
  end

  def log_in_to_site
    @agent.get(@login_url)
    form = @agent.page.forms[1]
    form['login'] = @username
    form['password'] = @password
    form.submit
  end

  def download_pending_delete_domains_text_file
    file = @agent.get(@pending_delete_domain_txt_file_url)
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
    wanted_domain = WantedDomain.new(name: domain_array[0], tld: "#{domain_array[1]}")

    if wanted_domain.valid? && wanted_domain.save
      WantedDomainCheckEnqueuer.queue(wanted_domain.tld, wanted_domain.id)
    end
  end

  def delete_file
    File.delete(@txt_filename)
  end
end
