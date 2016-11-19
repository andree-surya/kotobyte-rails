class WordsController < ApplicationController

  def search
    @query = params[:query]
    
    if @query.present?
      @results = WordsRepository.new.search_words(@query)

    else
      redirect_to root_path
    end
  end
end
