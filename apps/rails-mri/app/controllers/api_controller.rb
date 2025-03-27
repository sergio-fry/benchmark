class ApiController < ApplicationController
  def json
    render json: { status: 'ok', message: 'Hello World' }
  end
end