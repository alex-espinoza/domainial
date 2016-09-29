namespace :dictionaries do
  desc 'Scrape all words from dictionary.com'
  task get_all_words: :environment do
    Dictionary.scrape_all
  end
end
