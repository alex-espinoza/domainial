class CompetitorDomain < ApplicationRecord
  # active can have 2 states: 0 = not active (sold/auction ended), 1 = auction ongoing
  validates :name, :tld, :price, :source, :active, presence: true

  def name_with_tld
    "#{self.name}.#{self.tld}"
  end

  def pretty_date(datetime)
    (datetime && datetime.to_formatted_s(:long)) || ''
  end
end
