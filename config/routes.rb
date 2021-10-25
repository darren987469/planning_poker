# frozen_string_literal: true

Rails.application.routes.draw do
  resources :games, only: %i[index show new create], param: :code
  resources :users, only: %i[new create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'welcome#index'
end
