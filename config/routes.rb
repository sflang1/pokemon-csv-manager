Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # The unique identifier is the name, as is the one param that doesn't repeat
  # from pokemon to pokemon in the list we are given
  resources :pokemons, param: :name
end
