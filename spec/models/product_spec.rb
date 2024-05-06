require 'rails_helper'

RSpec.describe Product, type: :model do

  describe "presence and validation of columns" do
    let(:store) {Store.create(name: "Bompreço", user: create(:user))}
    it "checks if the table contains the correct attributes" do
        product = Product.create(title: "Macarrão", price: 1.99, store: store)
        expect(product["title"]). to eq "Macarrão"
        expect(product["price"]). to eq 1.99
    end
  end
end
