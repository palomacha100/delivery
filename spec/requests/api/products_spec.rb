require "rails_helper"

RSpec.describe "/stores/:store_id/products", type: :request do
  let(:user) {
    create(:user)
  }

  let(:credential) { Credential.create_access(:seller) }

  let(:signed_in) { api_sign_in(user, credential) }

  let(:store) {
    Store.create(name: 'Burguer King', user: user)
  }
    describe "GET /show" do
      it "renders a successful response with products data" do
        Product.create title: "panqueca", price: 5, description: "Saborosa panqueca", 
        category: "almoço",
        portion: "2 pessoas",
        store: store
        get "/stores/#{store.id}/products",
        headers: {"Accept" => "application/json", "Authorization" => "Bearer #{signed_in["token"]}"}
        json = JSON.parse(response.body)
        expect(json["data"][0]["title"]).to eq "panqueca"
        expect(json["data"][0]["category"]).to eq "almoço"
        expect(json["data"][0]["price"].to_i).to eq 5
      end
    end

    describe "POST /products" do
        it "creates product successfully" do
            post "/stores/#{store.id}/products",
            headers: {"Accept" => "application/json", "Authorization" => "Bearer #{signed_in["token"]}"},
            params: {
                product: {
                    title: "panqueca", price: 5, description: "Saborosa panqueca", 
                    category: "almoço",
                    portion: "2 pessoas"
                }
            }
            json = JSON.parse(response.body)
            expect(json["id"]).to eq 1
            expect(json["title"]).to eq "panqueca"
            expect(response.status).to eq 201
        end
        it "adds error if product registration is incomplete" do
            post "/stores/#{store.id}/products",
            headers: {"Accept" => "application/json", "Authorization" => "Bearer #{signed_in["token"]}"},
            params: {
                product: {
                    title: "", price:"", description: "Panqueca", 
                    category: "",
                    portion: ""
                }
            }
            json = JSON.parse(response.body)
            expect(json["title"]).to eq ["can't be blank", "is too short (minimum is 3 characters)"]
            expect(json["price"]).to eq ["can't be blank", "is not a number"]
            expect(json["description"]).to eq ["is too short (minimum is 10 characters)"]
            expect(json["category"]).to eq ["can't be blank"]
            expect(json["portion"]).to eq ["can't be blank"]
            expect(response.status).to eq 422
        end
    end


    
end