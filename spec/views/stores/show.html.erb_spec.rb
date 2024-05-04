require 'rails_helper'

RSpec.describe "stores/show", type: :view do
  let(:user) {
    user = User.new(email: "user@example.com", password: "123456", password_confirmation: "123456", role: :seller)
    user.save
    user
  }

  before(:each) do
    assign(:store, Store.create!(
      name: "Name",
      user: user
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
