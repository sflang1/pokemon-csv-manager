class PokemonsController < ApplicationController
  before_action     :load_resource, only: [:show, :update, :destroy]

  def index
    # always return paged results
    pokemons = PokemonCsv.page(params[:page], params[:per_page])
    render_success(pokemons.map(&:api_response))
  end

  def create
    pokemon = PokemonCsv.create(create_params)

    render_success(pokemon.api_response)
  end

  def show
    render_success(@pokemon.api_response)
  end

  def update
    success = @pokemon.update(update_params)

    success ? render_success(@pokemon.api_response) : render_error('Unexpected error happened.', 500)
  end

  def destroy
    success = @pokemon.destroy
    success ? render_success(@pokemon.api_response) : render_error('Unexpected error happened.', 500)
  end

  private
  def create_params
    params.require(:pokemon)
      .permit(:number, :name, :type1,
        :type2, :total, :hp, :attack,
        :defense, :sp_atk, :sp_def,
        :speed, :generation, :legendary)
  end

  # don't allow to change the name
  def update_params
    params.require(:pokemon)
      .permit(:number, :type1,
        :type2, :total, :hp, :attack,
        :defense, :sp_atk, :sp_def,
        :speed, :generation, :legendary)
  end

  def load_resource
    # The id used for finding the pokemons is its name, as it is the
    # unique key from the list we got
    @pokemon = PokemonCsv.find_by_name(params[:name])
  end
end