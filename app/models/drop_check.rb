class DropCheck < ApplicationRecord
  belongs_to :wanted_domain

  def self.check_availability_on_drop
    todays_io_drop_time = Time.now.utc.beginning_of_day + 30.minutes
    domains_to_be_checked = WantedDomain.where(grace_period_ends_date: todays_io_drop_time, interested?: 1)

    domains_to_be_checked.each do |domain|
      DropCheckWorker.perform_async(domain.id)
    end
  end
end
