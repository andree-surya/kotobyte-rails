Rails.application.routes.draw do
  
  root 'home#index'

  get 'about', to: 'home#about', as: :about
  get 'words', to: 'words#index', as: :search_words
  get 'kanji/:literal', to: 'kanji#show', as: :kanji
end
