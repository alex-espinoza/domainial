class WantedDomain < ApplicationRecord
  SUPPORTED_TLDS = ['io', 'to']
  PROXY_LIST = [
    ['139.162.37.116',  '80'],
    ['142.0.128.217', '8088'],
    ['23.91.96.251',  '80'],
    ['97.77.104.22',  '80'],
    ['54.187.81.118', '80'],
    ['23.91.97.54', '80'],
    ['47.88.195.233', '3128'],
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
      WantedDomainCheckEnqueuer.queue(domain.tld, domain.id)
    end
  end

  def self.io_drop_time
    Time.now.utc.beginning_of_day + 30.minutes
  end

  def name_with_tld
    "#{self.name}.#{self.tld}"
  end

  def whois_link_for_tld
    case self.tld
    when 'io'
      "http://nic.io/go/whois/#{self.name_with_tld}"
    when 'to'
      "https://www.tonic.to/whois?#{self.name_with_tld}"
    end
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
