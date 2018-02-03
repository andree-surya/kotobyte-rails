class WordsController < ApplicationController

  def index 
    @query = params[:query]
    
    if @query.present?
      @words = DictionaryDatabase.new.search_words(@query)

    else
      redirect_to root_path
    end
  end
end
