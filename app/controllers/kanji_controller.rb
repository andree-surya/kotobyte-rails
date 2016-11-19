class KanjiController < ApplicationController

  def show
    @kanji = KanjiRepository.search(params[:literal]).first

    if @kanji.nil?
      render status: :not_found
    end
  end
end
