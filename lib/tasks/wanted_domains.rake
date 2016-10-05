namespace :wanted_domains do
  desc 'Check the status of all wanted domains'
  task check_availability: :environment do
    WantedDomain.queue_all_unchecked
  end

  desc 'Check Nic.IO for domains released today'
  task check_nic_io_domains_released_today: :environment do
    n = NicIOReleasedTodayScraperWorker.new
    n.perform
  end

  desc 'Check ExpiredDomains.net for domains pending delete'
  task check_expired_domains_for_pending_delete: :environment do
    ed = ExpiredDomainsPendingDeleteScraperWorker.new
    ed.perform
  end

  desc 'Check ExpiredDomains.net for deleted domains'
  task check_expired_domains_for_deleted: :environment do
    ed = ExpiredDomainsDeletedScraperWorker.new
    ed.perform
  end
end
