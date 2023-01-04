class ApplicationController < ActionController::Base

  def current_user
    return nil if bearer_token.nil?
    return @current_user if @current_user.present?
    payload = JWT.decode(bearer_token, Rails.application.secrets.secret_key_base)
    user_id = payload.first["user_id"]
    @current_user = User.find_by(id: user_id)
  end

  def authenticate_current_user
    if current_user.nil?
      head(:unauthorized)
    end
  end

  private

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

end
