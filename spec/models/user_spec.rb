require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { User.new }


  it { should have_db_column(:first_name).of_type(:string) }
  it { should have_db_column(:last_name).of_type(:string) }
  it { should have_db_column(:title).of_type(:string) }
  it { should have_db_column(:manager_id).of_type(:integer) }
  it { should have_db_column(:username).of_type(:string) }
  it { should have_db_column(:password_digest).of_type(:string) }

  it { should validate_length_of(:password).is_at_least(6) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:password_digest) }
  it { should have_many(:direct_reports).class_name(:User) }
  it { should belong_to(:manager).optional.class_name(:User) }

  ##
  # Make sure you finish the validation specs before moving on
  ##

  describe "#name" do
    it "returns the user's full name" do
      u = create(:user, first_name: "Michael", last_name: "Scott", password: '123456')
      
      expect(u.name).to eq("Michael Scott")
    end
  end

  describe "user creation" do
    it "sets the username to first_initial.last_name" do
      u = User.create!(first_name: 'Michael', last_name: "Scott", title: "Manager", password: "password123")
      expect(u.username).to eq("m.scott")
    end

    # you can use has_secure_password for this
    it 'does not save passwords to the database' do
      user = User.create!(first_name: 'Michael', last_name: "Scott", title: "Manager", password: "password123")
      expect(user.reload.password).not_to be('abcdef')
    end

    it 'encrypts the password using BCrypt' do
      expect(BCrypt::Password).to receive(:create)
      User.new(username: 'jack_bruce', password: 'abcdef')
    end
  end

  describe "#destroy" do
    let!(:manager) { create(:user) }
    let!(:direct_report) { create(:user, manager: manager )}
    it "should nullify manager_id of direct_reports on destroy" do
      manager.destroy!
      expect(direct_report.reload.manager_id).to be_nil
    end
	end
	
	describe "#token" do
		it "returns a JWT token encoded with the user's id" do  # expected shape: { user_id: "1" }
			token = JWT.decode(user.token, Rails.application.secrets.secret_key_base)[0]
			expect(token["user_id"]).to eq(user.id)
		end
	end

  describe 'validations' do
    let!(:manager) { create(:user) }
    let!(:direct_report) { create(:user, manager: manager )}
    let!(:second_level_direct_report) { create(:user, manager: direct_report) }
    
    it "is valid with valid attributes" do
      user.first_name = "Michael"
      user.last_name = "Scott"
      user.title = "Manager"
      user.password = "password123"
  
      expect(user).to be_valid
    end

    it "does not allow a user to be the direct report of one of their direct reports or descendants " do
      expect { manager.reload.update!(manager: direct_report) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { manager.reload.update!(manager: second_level_direct_report) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end
