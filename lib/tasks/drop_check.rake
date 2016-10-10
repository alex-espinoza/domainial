namespace :drop_check do
  desc 'Prepare interested wanted domains to collect drop check information'
  task prepare: :environment do
    DropCheck.check_availability_on_drop
  end

  desc 'Rev up the engines to purchase!'
  task purchase_domain: :environment do
    todays_io_drop_time = WantedDomain.io_drop_time
    interested_domains = WantedDomain.where(grace_period_ends_date: todays_io_drop_time, interested?: 1)
    aws_lambda = Aws::Lambda::Client.new

    interested_domains.each do |domain|
      payload = {domain: domain.name_with_tld}

      aws_lambda.invoke({
        function_name: 'purchaseDomain',
        invocation_type: 'Event',
        payload: payload.to_json
      })
    end
  end
end
