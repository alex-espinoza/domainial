class DropCheckCheckEnqueuer
  def self.queue(domain_tld, domain_id)
    case domain_tld
    when 'io'
      IODropCheckWorker.perform_async(domain_id)
    when 'to'
      TODropCheckWorker.perform_async(domain_id)
    end
  end
end
