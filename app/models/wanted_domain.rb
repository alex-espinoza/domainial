class WantedDomain < ApplicationRecord
  # checked? can have 3 states: 0 = not checked, 1 = checked, 2 = scheduled to be checked again
  # status_code can have 2 states: 0 = not available, 1 = available
  # backorder_status can have 2 states: 0 = not backordered, 1 = already backordered
  validates :name, uniqueness: { scope: :tld }

  def self.queue_all_unchecked
    domains_to_be_checked = WantedDomain.where(checked?: [0, 2])

    domains_to_be_checked.each do |domain|
      WantedDomainCheckWorker.perform_async(domain_id: domain.id)
    end
  end

  def name_with_tld
    "#{self.name}#{self.tld}"
  end

  def is_available_class
    self.status_code == 1 ? 'table-success' : ''
  end

  def pretty_date(datetime)
    (datetime && datetime.to_formatted_s(:long)) || ''
  end
end
