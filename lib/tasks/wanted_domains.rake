namespace :wanted_domains do
  desc 'Check the status of all wanted domains'
  task check_availability: :environment do
    domains_to_be_checked = WantedDomain.where(checked?: [0, 2])

    domains_to_be_checked.each do |domain|
      WantedDomainCheckWorker.perform_async(domain.id)
    end
  end
end
