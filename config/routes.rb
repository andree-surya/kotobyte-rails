Rails.application.routes.draw do
  
  root 'home#index'

  get 'about', to: 'home#about', as: :about
  get 'search', to: 'words#search', as: :search
  get 'kanji/:literal', to: 'kanji#show', as: :kanji
end
