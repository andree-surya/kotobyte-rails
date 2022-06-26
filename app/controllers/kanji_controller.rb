class KanjiController < ApplicationController

  #
  # Search for a single Kanji entry matching the given literal
  #
  # @return [<Kanji>]
  #
  def show
    @kanji = DictionaryDatabase.new.search_kanji(params[:literal]).first

    if @kanji.nil?
      render status: :not_found
    end
  end
end
