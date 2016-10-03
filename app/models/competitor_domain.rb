class CompetitorDomain < ApplicationRecord
  # active can have 2 states: 0 = not active (sold/auction ended), 1 = auction ongoing
  validates_presence_of :name, :tld, :price, :source, :active
end
