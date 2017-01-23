class KanjiController < ApplicationController

  def index
    @results = KanjiRepository.new.search_kanji(params[:query])
  end

  def show
    @kanji = KanjiRepository.new.search_kanji(params[:literal]).first

    if @kanji.nil?
      render status: :not_found
    end
  end
end
