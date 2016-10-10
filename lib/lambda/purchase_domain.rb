#!/usr/bin/env ruby
require 'json'
require 'xmlrpc/client'
require 'active_support/core_ext/numeric/time'
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
    # @drop_time = DateTime.now.utc.beginning_of_day + 30.minutes + 13.seconds
    @drop_time = DateTime.now.utc.beginning_of_day + (30 * 60) + 13
  end

  def prepare_purchase_domain
    puts "Preparing to purchase '#{@domain}'"
    while true
      if DateTime.now.utc >= @drop_time
        puts "TIME: " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
        spam_purchase_domain
        break
      else
        #puts "NOT YET TIME: " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
      end
    end
  end

  def spam_purchase_domain
    sleep 0.5 # sleep for half a second in case domains are not released right on the second, tweak this to test puchase timing

    10.times do |i|
      begin
        puts "Attempt #{i}: " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
        response = purchase_domain

        if response['step'] == 'BILL'
          puts "Attempt #{i} SUCCESSFUL: " + DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
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

  # def get_transfer_authorization_code
  #   info = @server.call("domain.info", @api_key, @domain)
  #   info['authinfo']
  # end
end

args = JSON.parse(ARGV[0])
domain = args['domain']

dpw = DomainPurchaserWorker.new(domain)
dpw.prepare_purchase_domain

