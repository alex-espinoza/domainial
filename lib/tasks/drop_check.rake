namespace :drop_check do
  desc 'Prepare interested wanted domains to collect drop check information'
  task prepare: :environment do
    DropCheck.check_availability_on_drop
  end

  desc 'Rev up the engines to purchase!'
  task purchase_domain: :environment do
    dp = DomainPurchaserWorker.new('shc.io')
    dp.prepare_purchase_domain
  end
end
