class DropCheck < ApplicationRecord
  belongs_to :wanted_domain

  def self.check_availability_on_drop
    hour_before_now = Time.now.utc - 1.hour
    hour_after_now = Time.now.utc + 1.hour
    domains_to_be_checked = WantedDomain.where(grace_period_ends_date: hour_before_now..hour_after_now)

    domains_to_be_checked.each do |domain|
      DropCheckWorker.perform_async(domain.id)
    end
  end
end
