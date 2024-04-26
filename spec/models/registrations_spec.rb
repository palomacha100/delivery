RSpec.describe "registrations", type: :request do
    let(:credential) {
        Credential.create_access(:buyer)
    }

    describe "POST /new" do
        it "creates a buyer user" do
            post(
                create_registration_url,
                headers: {
                    "Accept" => "application/json",
                    "X-API-KEY" => credential.key
                },
                params: {
                    user: {
                        email: "admin_user@example.com",
                        password: "123456",
                        password_confirmation: "123456"
                    }
                }
            )
            user = User.find_by(email: "admin_user@example.com")
        
            expect(response).to be_successful
            expect(user).to be_buyer
        end
    end

    it "fail to create user without credentials" do
        post(
            create_registration_url,
            headers: {"Accept" => "application/json"},
            params: {
                user: {
                email: "admin_user@example.com",
                password: "123456",
                password_confirmation: "123456"
                }
            }
        )
        expect(response).to be_unprocessable
    end
end