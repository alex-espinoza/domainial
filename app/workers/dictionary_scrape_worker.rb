class DictionaryScrapeWorker
  include HTTParty
  include Sidekiq::Worker
  base_uri 'http://www.dictionary.com/list'
  sidekiq_options queue: ENV['WANTED_DOMAIN_CHECK_AVAILABILITY'],
                  retry: 5,
                  backtrace: 3

  sidekiq_retry_in do |count|
    90
  end

  def perform(letter, last_page_number)
    letter_page_range = (1..last_page_number)

    letter_page_range.each do |page_number|
      response = make_http_request(letter, page_number)
      page_content = get_page_content(response)
      parse_all_words(letter, page_content)
    end
  end

  def make_http_request(letter, page_number)
    self.class.get("/#{letter}/#{page_number}")
  end

  def get_page_content(response)
    Nokogiri::HTML(response)
  end

  def parse_all_words(letter, page_content)
    word_elements = page_content.css('.words-list')[0].css('ul')[0].css('li')

    word_elements.each do |element|
      word = element.css('span')[0].text
      definition_url = element.css('span')[1].css('a')[0]['href']

      save_word(letter, word, definition_url)
    end
  end

  def save_word(letter, word, definition_url)
    Dictionary.create(word: word,
                      first_character: letter,
                      definition_url: definition_url)
  end
end
