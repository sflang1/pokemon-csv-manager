class ApplicationController < ActionController::API
  rescue_from PokemonCsv::RecordInvalid,              with: :bad_request
  rescue_from PokemonCsv::RecordNotFound,             with: :bad_request

  def render_success(data)
    render json: { success: true, data: data, message: '' }
  end

  def render_error(message, error_code)
    render json: { success: false, data: [], message: message }, status: error_code
  end

  def bad_request(exception)
    render_error(exception.message, 400)
  end
end
