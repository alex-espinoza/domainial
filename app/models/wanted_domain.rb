class WantedDomain < ApplicationRecord
  validates :name, uniqueness: true

  def name_with_tld
    "#{self.name}#{self.tld}"
  end
end
