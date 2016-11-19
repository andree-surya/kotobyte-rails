namespace :index do

  desc 'Reset all dictionary indices'
  task all: [:words, :kanji]

  desc 'Reset words dictionary index'
  task words: :environment do
    WordsIndexer.new.run
  end

  desc 'Reset Kanji dictionary index'
  task kanji: :environment do
    KanjiIndexer.new.run
  end
end
