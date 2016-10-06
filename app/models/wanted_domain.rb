class WantedDomain < ApplicationRecord
  has_many :drop_checks
  # checked? can have 3 states: 0 = not checked, 1 = checked, 2 = scheduled to be checked again
  # interested? can have 2 states: 0 = not interested, 1 = interested
  # status_code can have 2 states: 0 = not available, 1 = available
  # backorder_status can have 2 states: 0 = not backordered, 1 = already backordered
  validates :name, uniqueness: { scope: :tld }

  def self.queue_all_unchecked
    domains_to_be_checked = WantedDomain.where(checked?: [0, 2])

    domains_to_be_checked.each do |domain|
      WantedDomainCheckWorker.perform_async(domain.id)
    end
  end

  def name_with_tld
    "#{self.name}#{self.tld}"
  end

  def is_available_css_class
    self.status_code == 1  && self.backorder_status != 1 ? 'table-success' : ''
  end

  def is_backordered_css_class
    self.backorder_status == 1 && self.status_code != 1 ? 'table-warning' : ''
  end

  def is_interested_css_button_color
    self.interested? == 1 ? 'btn-danger' : 'btn-success'
  end

  def is_interested_button_text
    self.interested? == 1 ? 'Remove' : 'Interested'
  end

  def is_being_checked_button_text
    self.checked? == 1 ? 'Recheck' : 'Checking'
  end

  def pretty_date(datetime)
    (datetime && datetime.to_formatted_s(:long)) || ''
  end
end
