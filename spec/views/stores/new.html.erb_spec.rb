require 'rails_helper'

RSpec.describe "stores/new", type: :view do
  let(:user) {
    user = User.new(email: "user@example.com", password: "123456", password_confirmation: "123456")
    user.save
    user
  }
  
  before(:each) do
    assign(:store, Store.new(
      name: "MyString",
      user: user
    ))
  end

  it "renders new store form" do
    render

    assert_select "form[action=?][method=?]", stores_path, "post" do

      assert_select "input[name=?]", "store[name]"
    end
  end
end
