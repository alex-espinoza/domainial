namespace :wanted_domains do
  desc 'Check the status of all wanted domains'
  task check_availability: :environment do
    WantedDomain.queue_all_unchecked
  end
end
