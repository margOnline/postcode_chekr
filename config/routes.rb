# frozen_string_literal: true

Rails.application.routes.draw do
  get 'postcode_searches/create'
  get 'home/index'
  get 'home/create'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'

  resources :postcode_searches, only: [:create]
end
