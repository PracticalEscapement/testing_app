require 'rails_helper'

RSpec.describe "Users", type: :request do

	# For the expected response shape, checkout the schemas defined in spec/support/api/schemas/

  let!(:user) { create(:user, password: "password123") }
  let!(:auth_header) {{
    "Authorization": "Bearer #{user.token}", # if you haven't implemented the token method yet, go back to the model spec!
  } }

    describe "index" do
      before do
        5.times do
          new_user = create(:user)
          new_user.update!(manager: user)
        end
      end
      context 'with valid credentials' do
        before(:each) do
          get '/api/users', headers: auth_header
        end

        it "has HTTP status 200" do
          expect(response).to have_http_status(200)
        end

        it "returns a list of the current user's direct reports" do
          #expect(response).to match_response_schema("users")
          expect(JSON.parse(response.body).length).to eq(5)
        end
      end
        
      context 'with invalid credentials' do 
        before(:each) { get '/api/users', headers: { Authorization: "fake_token"} }
        it "has HTTP status 401" do
          expect(response).to have_http_status(401)

        end
      end

    end
    describe 'update' do
      let!(:direct_report) { create(:user, manager: user )}
      let!(:non_direct_report) { create(:user, { first_name: "Other", last_name: "User"}) }

      context "when target is direct report of current_user" do
        before(:each) {put "/api/users/#{direct_report.id}", headers: auth_header, params: { user: { first_name: "Test" }} }

        it "has HTTP status 200" do
          expect(response).to have_http_status(200)
        end

        it "updates the user" do
          expect(direct_report.reload.name).to eq("Test #{direct_report.last_name}")
        end
        
        it "returns the updated user" do
          expect(JSON.parse(response.body)["name"]).to eq("Test #{direct_report.last_name}")
        end
      end

      context "when target is not a direct report of current user" do
        before(:each) { put "/api/users/#{non_direct_report.id}", headers: auth_header, params: { user: { first_name: "Test" }} }

        it "has HTTP status 403" do
          expect(response).to have_http_status(403)
        end

        it "does not update the user" do
          expect(non_direct_report.reload.name).to eq("Other User")
        end
      end
  end

  describe 'create' do
    
    context 'with valid params' do
      before(:each) do
        post '/api/users', headers: auth_header, params: { user: { first_name: "Tony", last_name: "Stark", title: "Ironman", password: "password123" } }
      end

      it "has HTTP status 200" do
        expect(response).to have_http_status(200)
      end

      it "creates the user" do
        expect(User.find_by_title("Ironman")).to be_present
      end
  
      it "returns the created user" do
        expect(response).to match_response_schema("user")
        expect(JSON.parse(response.body)["name"]).to eq("Tony Stark")
      end
      
      it "assigns the current_user as manager" do
        expect(User.find_by_title("Ironman").manager).to eq(user)
      end
    end

    context 'without valid params' do
      before(:each) do
        post '/api/users', headers: auth_header, params: { user: { first_name: "Tony" } }
      end

      it "has HTTP status 400" do
        expect(response).to have_http_status(400)
      end

    end

    

  end

  describe 'destroy' do
    let!(:direct_report) { create(:user, manager: user )}
    let!(:non_direct_report) { create(:user, { first_name: "Other", last_name: "User"}) }

    context "when current_user is the target's manager" do
      before(:each) do
        delete "/api/users/#{direct_report.id}", headers: auth_header
      end
      
      it 'has HTTP status 200' do
        expect(response).to have_http_status(200)
      end

      it "destroys the user" do
        expect(User.find_by(id: direct_report.id)).to_not be_present
      end
    end

    context "when current_user is not the target's manager" do
      before(:each) do
        delete "/api/users/#{non_direct_report.id}", headers: auth_header
      end

      it "has http status 403" do
        expect(response).to have_http_status(403)
      end

      it "does not destroy the user" do
        expect(User.find_by(id: non_direct_report.id)).to be_present
      end
    end
  end

end
