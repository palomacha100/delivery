FactoryBot.define do
    factory :user do
      email { "john@example.com" }
      password { "kosjksjd123235@" }
      password_confirmation { "kosjksjd123235@" }
      role {:seller}
    end
  
    factory :store do
      name { "Greatest store" }
      association :user 
    end
  end