class DropCheck < ApplicationRecord
  belongs_to :wanted_domain

  def self.check_io_availability_on_drop
    todays_io_drop_time = WantedDomain.io_drop_time
    domains_to_be_checked = WantedDomain.where(tld: 'io', grace_period_ends_date: todays_io_drop_time, interested?: 1)

    domains_to_be_checked.each do |domain|
      DropCheckEnqueuer.queue(domain.tld, domain.id)
    end
  end

  def self.check_to_availability
    domains_to_be_checked = WantedDomain.where(tld: 'to', grace_period_ends_date: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day, interested?: 1)

    time_now = Time.now.utc
    drop_check_start = Time.now.utc.beginning_of_day + 14.hours + 20.minutes
    drop_check_end = Time.now.utc.beginning_of_day + 14.hours + 40.minutes

    if (time_now > drop_check_start) && (time_now < drop_check_end)
      domains_to_be_checked.each do |domain|
        DropCheckEnqueuer.queue(domain.tld, domain.id)
      end
    end
  end
end
