require "rails_helper"

RSpec.describe "/stores/:store_id/products", type: :request do
  

    describe "GET /show" do
      it "renders a successful response with products data" do
        get stores_url
        expect(response). to be_successful
        expect(response.body).to include "Store 1"
        expect(response.body).to include "Store 2"
      end
    end

    describe "POST /create" do
      it "creates a new Store" do
        store_attributes = {
          name: "What a great store",
          user_id: user.id
        }

        expect {
          post stores_url, params: {store: store_attributes } 
      }.to change(Store, :count).by(1)

      expect(Store.find_by(name: "What a great store").user).to eq user
      end
    end

  end
  
  describe "GET /show" do
    it "renders a successful response with stores data" do
      store = Store.create!(
        name: "New Store",
        user: user
        )
      get "/stores/#{store.id}", 
      headers: {
        "Accept" => "application/json", 
        "Authorization" => "Bearer #{signed_in["token"]}"
      }
    
      
      json = JSON.parse(response.body)

      expect(json["name"]).to eq "New Store"
    end
  end
end