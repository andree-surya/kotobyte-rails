class KanjiController < ApplicationController

  def show
    @kanji = DictionaryDatabase.new.search_kanji(params[:literal]).first

    if @kanji.nil?
      render status: :not_found
    end
  end
end
