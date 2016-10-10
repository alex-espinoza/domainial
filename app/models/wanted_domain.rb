class WantedDomain < ApplicationRecord
  SUPPORTED_TLDS = ['io', 'to']
  PROXY_LIST = [
    ['97.77.104.22',  '80'],
    ['192.151.147.178', '3128'],
    ['173.161.0.227', '80'],
    ['54.69.195.67',  '80'],
    ['65.79.202.170', '3128'],
    ['152.160.35.171',  '80'],
    ['52.88.195.8', '80'],
    ['47.88.138.190', '8080'],
    ['97.107.129.183',  '80'],
    ['45.32.138.150', '8080'],
    ['104.236.54.155',  '8080'],
  ]

  has_many :drop_checks
  # checked? can have 3 states: 0 = not checked, 1 = checked, 2 = scheduled to be checked again
  # interested? can have 2 states: 0 = not interested, 1 = interested
  # status_code can have 2 states: 0 = not available, 1 = available
  # backorder_status can have 2 states: 0 = not backordered, 1 = already backordered
  validates :name, :tld, :checked?, :interested?, presence: true
  validates :name, uniqueness: { scope: :tld }
  validates :tld, inclusion: { in: SUPPORTED_TLDS }

  def self.queue_all_unchecked
    domains_to_be_checked = WantedDomain.where(checked?: [0, 2])

    domains_to_be_checked.each do |domain|
      WantedDomainCheckWorker.perform_async(domain.id)
    end
  end

  def self.io_drop_time
    Time.now.utc.beginning_of_day + 30.minutes
  end

  def name_with_tld
    "#{self.name}.#{self.tld}"
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

  def disable_if_being_checked
    self.checked? == 1 ? '' : 'disabled'
  end

  def pretty_date(datetime)
    (datetime && datetime.to_formatted_s(:long)) || ''
  end
end
