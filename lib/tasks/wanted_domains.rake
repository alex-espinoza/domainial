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

  desc 'Check Freshdrop.com for domains pending delete'
  task check_fresh_drop_for_pending_delete: :environment do
    fd = FreshDropPendingDeleteScraperWorker.new
    fd.perform
  end

  desc 'Check Park.io for domains pending delete'
  task check_park_io_for_pending_delete: :environment do
    pi = ParkIOPendingDeleteAPIWorker.new
    pi.perform
  end

  desc 'Recheck status of all io domains that were recently dropped'
  task recheck_all_recently_dropped_io_domains: :environment do
    todays_drop_time = WantedDomain.io_drop_time
    recently_dropped_domains = WantedDomain.where(tld: 'io', grace_period_ends_date: todays_drop_time)

    recently_dropped_domains.each do |domain|
      WantedDomainCheckEnqueuer.queue(domain.tld, domain.id)
    end
  end

  desc 'Recheck status of all to domains that were recently dropped'
  task recheck_all_recently_dropped_to_domains: :environment do
    recently_dropped_domains = WantedDomain.where(tld: 'to', grace_period_ends_date: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day)

    recently_dropped_domains.each do |domain|
      WantedDomainCheckEnqueuer.queue(domain.tld, domain.id)
    end
  end
end
