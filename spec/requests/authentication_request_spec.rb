require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let!(:user) { create(:user, password: "password123") }

  describe '/login' do
    it "returns a JWT with valid credentials" do
      headers = {
        "ACCEPT" => "application/json",     # This is what Rails 4 accepts
        "HTTP_ACCEPT" => "application/json" # This is what Rails 3 accepts
      }
      post '/api/login', params: { username: user.username, password: "password123" }

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["token"]) .to be_present
      expect(JWT.decode(JSON.parse(response.body)["token"], Rails.application.secrets.secret_key_base)[0]["user_id"]).to eq(user.id)
    end

    it "returns a 401 error with invalid credentials" do
      post '/api/login', params: { username: user.username, password: "abcdef123" }

      expect(response).to have_http_status(401)
    end
  end
end
