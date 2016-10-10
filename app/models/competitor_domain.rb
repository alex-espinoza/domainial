class CompetitorDomain < ApplicationRecord
  # active can have 2 states: 0 = not active (sold/auction ended), 1 = auction ongoing
  validates :name, :tld, :price, :source, :active, presence: true
end
