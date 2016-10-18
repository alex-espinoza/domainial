class WantedDomain < ApplicationRecord
  SUPPORTED_TLDS = ['io', 'to']
  PROXY_LIST = [
    ["104.196.181.103", "80"],
    ["23.251.143.37", "80"],
    ["104.155.122.225", "80"],
    ["104.199.122.125", "80"],
    ["104.199.213.116", "80"],
    ["104.199.122.250", "80"],
    ["104.196.162.185", "80"],
    ["104.155.120.2", "80"],
    ["104.196.194.229", "80"],
    ["104.199.117.250", "80"],
    ["146.148.67.65", "80"],
    ["104.199.120.218", "80"],
    ["104.199.26.155",  "80"],
    ["104.196.222.28",  "80"],
    ["104.155.127.61",  "80"],
    ["104.196.122.215", "80"],
    ["104.196.199.8", "80"],
    ["104.199.26.9",  "80"],
    ["130.211.171.192", "80"],
    ["104.199.122.77",  "80"],
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
