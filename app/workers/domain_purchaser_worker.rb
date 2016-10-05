require 'xmlrpc/client'
XMLRPC::Config::ENABLE_NIL_PARSER = true

class ZlibParserDecorator
  def initialize(parser)
    @parser = parser
  end

  def parseMethodResponse(responseText)
    @parser.parseMethodResponse(Zlib::GzipReader.new(StringIO.new(responseText)).read)
  end

  def parseMethodCall(*args)
    @parser.parseMethodCall(*args)
  end
end

class DomainPurchaserWorker
  def initialize(domain)
    # Test
    #@api_key = 'yoZCBxqi9oIzQ1H6KBkbAf5C'
    #@gandi_url = 'https://rpc.ote.gandi.net/xmlrpc/'

    # Production
    @api_key = 'G1TEATAvI3WLfKFBIXVrFiTP'
    @gandi_url = 'https://rpc.gandi.net/xmlrpc/'

    @server = XMLRPC::Client.new2(@gandi_url)
    @server.http_header_extra = {'Accept-Encoding' => 'gzip'}
    @parser = ZlibParserDecorator.new(@server.send(:parser))
    @server.set_parser(@parser)

    @domain = domain
    @gandi_handle = 'AE2501-GANDI'
    @domain_registration_info = {
      'owner' => @gandi_handle,
      'admin' => @gandi_handle,
      'bill' => @gandi_handle,
      'tech' => @gandi_handle,
      'duration' => 1,
      'nameservers' => ['a.dns.gandi.net', 'b.dns.gandi.net',
                      'c.dns.gandi.net']
    }
    @association_spec = {
      'domain' => 'aspria.net',
      'owner'=> true,
      'admin'=> true
    }
    @op = nil
    @drop_time = DateTime.now.utc.beginning_of_day + 30.minutes + 13.seconds
  end

  # def get_api_version_info
  #   @server.call('version.info', @api_key)
  # end

  # def get_own_contact_info
  #   @server.call('contact.list', @api_key)
  # end

  ### start here

  # def check_if_domain_available
  #   puts @server.call('domain.available', @api_key, [@domain]).inspect
  #   puts Time.now.utc
  # end

  # def spam_check_domain
  #   (1..50).each do |i|
  #     begin
  #       puts "Attempt #{i}"
  #       check_if_domain_available
  #     rescue
  #       next
  #     end
  #   end
  # end

  # def choose_contact
  #   puts @server.call('contact.can_associate_domain', @api_key, @gandi_handle, @association_spec)
  # end

  def prepare_purchase_domain
    sleep 5

    while true
      if DateTime.now.utc >= @drop_time
        puts "TIME: " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
        spam_purchase_domain
        break
      else
        puts "NOT YET TIME: " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
      end
    end
  end

  def spam_purchase_domain
    10.times do |i|
      begin
        puts "Attempt #{i} " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
        response = purchase_domain

        if response['step'] == 'BILL'
          puts "Attempt #{i} BILLED: " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
          break
        end
      rescue
        next
      end
    end
  end

  def purchase_domain
    @server.call('domain.create', @api_key, @domain, @domain_registration_info)
  end
end
