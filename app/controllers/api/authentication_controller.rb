class Api::AuthenticationController < ApplicationController
  def login
    user = User.find_by(username: params[:username])
    if user.present? && user.authenticate(params[:password])
      response.set_header("Authorization", "Bearer #{user.token}")
      render json: {token: user.token}
    else
      head(:unauthorized)
    end
  end
end
