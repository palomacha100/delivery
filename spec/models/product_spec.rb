require 'rails_helper'

RSpec.describe Product, type: :model do

  describe "presence and validation of columns" do
    let(:store) {Store.create(name: "Bompreço", user: create(:user))}
    it "checks if the table contains the correct attributes" do
        product = Product.create(title: "Macarrão", price: 1.99, store: store)
        expect(product["title"]). to eq "Macarrão"
        expect(product["price"]). to eq 1.99
    end

    it "validates minimum length of title" do
      product = Product.create(title: "Ma", price: 1.99, store: store)
      expect(product).not_to be_valid
      expect(product.errors[:title]).to include("is too short (minimum is 3 characters)")
    end
    it "validates price" do
      product = Product.create(title: "Macarrão", price: -5, store: store)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("must be greater than or equal to 0")
    end
    it "validates belongs to store" do
      product = Product.create(title: "Macarrão", price: 2)
      expect(product).not_to be_valid
      expect(product.errors[:store]).to include("must exist")
    end
  end
end
