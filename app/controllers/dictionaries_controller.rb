class DictionariesController < ApplicationController
  def index
  end

  def search
    starting_letters = "#{params[:starting_letters].downcase}%" || ""
    limit = params[:number_of_results].to_i || 20
    max_word_length = params[:max_word_length] || "99"

    @words = Dictionary.where('word LIKE :prefix AND length(word) <= :max_word_length', prefix: starting_letters, max_word_length: max_word_length).limit(limit).order('RANDOM()')

    flash.now[:notice] = "#{@words.size} results for '#{starting_letters}' limited to #{max_word_length} characters"
  end
end
