class DictionariesController < ApplicationController
  def index
  end

  def search
    nilify_empty_string_params

    starting_letters = "#{params[:search_field_strings][:starting_letters].downcase}%"
    max_word_length = params[:search_field_numbers][:max_word_length] || "100"
    exact_word_length = params[:search_field_numbers][:exact_word_length]
    limit = params[:search_field_numbers][:number_of_results] || 20

    @tlds = WantedDomain::SUPPORTED_TLDS
    @words = Dictionary.where('word LIKE :prefix', prefix: starting_letters)

    if exact_word_length
      @words = @words.where('length(word) = :exact_word_length', exact_word_length: exact_word_length)
    else
      @words = @words.where('length(word) <= :max_word_length', max_word_length: max_word_length)
    end

    @words = @words.limit(limit).order('RANDOM()')

    flash.now[:notice] = "#{@words.size} results for '#{starting_letters}' limited to #{max_word_length} characters"
    exact_word_length && flash.now[:notice] += " or exactly #{exact_word_length}"
  end

  private

  def nilify_empty_string_params
    params[:search_field_numbers].each {|field| params[:search_field_numbers][field].blank? && params[:search_field_numbers][field] = nil}
  end
end
