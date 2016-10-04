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
end
