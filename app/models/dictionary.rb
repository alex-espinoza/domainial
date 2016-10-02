class Dictionary < ApplicationRecord
  # interested? can have 2 states: 0 = not interested, 1 = interested
  validates :word, uniqueness: true

  def self.scrape_all
    letter_and_last_page_number = [
      ['a', 183],
      ['b', 166],
      ['c', 243],
      ['d', 133],
      ['e', 97],
      ['f', 107],
      ['g', 99],
      ['h', 116],
      ['i', 93],
      ['j', 31],
      ['k', 39],
      ['l', 98],
      ['m', 156],
      ['n', 85],
      ['o', 71],
      ['p', 212],
      ['q', 14],
      ['r', 112],
      ['s', 276],
      ['t', 135],
      ['u', 59],
      ['v', 42],
      ['w', 68],
      ['x', 5],
      ['y', 11],
      ['z', 11]
    ]

    letter_and_last_page_number.each do |pair|
      DictionaryScrapeWorker.perform_async(pair[0], pair[1])
    end
  end
end
