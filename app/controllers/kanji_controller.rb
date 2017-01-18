class KanjiController < ApplicationController

  def index
    @results = KanjiRepository.search(params[:query])
  end

  def show
    @kanji = KanjiRepository.search(params[:literal]).first

    if @kanji.nil?
      render status: :not_found
    end
  end
end
