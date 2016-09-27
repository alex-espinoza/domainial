class WantedDomain < ApplicationRecord
  validates :name, uniqueness: true
end
