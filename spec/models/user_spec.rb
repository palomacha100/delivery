require 'rails_helper'

RSpec.describe User, type: :model do
  describe "presence and validation of columns" do
    it "checks if the table contains the correct attributes" do
      user = User.create(email: "macarrao@hotmail.com", password: '123456', password_confirmation: '123456', role: :admin)
      expect(user).to be_valid
      expect(user.email).to eq "macarrao@hotmail.com"
      expect(user.role).to eq "admin"
    end
    
  end
end
