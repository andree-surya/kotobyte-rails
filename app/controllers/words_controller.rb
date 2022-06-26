class WordsController < ApplicationController

  #
  # Search Word dictionary entries matching the given query
  #
  # @return [Array<Word>]
  #
  def index 
    @query = params[:query]
    
    if @query.present?
      @words = DictionaryDatabase.new.search_words(@query)

    else
      redirect_to root_path
    end
  end
end
