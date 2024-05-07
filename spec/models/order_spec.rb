require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) {create(:user)}
  let(:user_buyer) {create(:user_buyer)}
  let(:store) {Store.create(name: "Burguer King", user: user)}
  describe "checking field validations" do
    it "creates a new order successfully" do
      order = Order.create(buyer: user_buyer, store: store)
      expect(order.buyer). to eq user_buyer
      expect(order.store). to eq store
      expect(order.state). to eq "created"
    end

    it "an error is expected to be added if the user has an invalid role" do
      order = Order.create(buyer: user, store: store)
      expect(order.errors[:buyer]). to include "should be a `user.buyer`"
    end
  end
end
