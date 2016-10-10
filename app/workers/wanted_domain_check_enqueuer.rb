class WantedDomainCheckEnqueuer
  def self.queue(domain_tld, domain_id)
    case domain_tld
    when 'io'
      IODomainCheckWorker.perform_async(domain_id)
    when 'to'
      #to
    end
  end
end
