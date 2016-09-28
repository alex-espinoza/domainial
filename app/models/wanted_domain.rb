class WantedDomain < ApplicationRecord
  # checked? can have 3 states: 0 = not checked, 1 = checked, 2 = scheduled to be checked again
  # status_code can have 2 states: 0 = not available, 1 = available
  validates :name, uniqueness: true

  def name_with_tld
    "#{self.name}#{self.tld}"
  end
end
