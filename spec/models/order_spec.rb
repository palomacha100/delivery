require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) {create(:user)}
  let(:store) {Store.create(name: "Burguer King", user: user)}
  describe "checking field validations" do
    it "an error is expected to be added if the user has an invalid role" do
      order = Order.create(buyer: user, store: store)
      expect(order.errors[:buyer]). to include "should be a `user.buyer`"
    end
  end
end
