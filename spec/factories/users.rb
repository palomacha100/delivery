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

    factory :user_two, class: User do
      email { "johntwo@example.com" }
      password { "kosjksjd123235@" }
      password_confirmation { "kosjksjd123235@" }
      role {:seller}
    end

    factory :user_three, class: User do
      email { "johnthree@example.com" }
      password { "kosjksjd123235@" }
      password_confirmation { "kosjksjd123235@" }
      role {:seller}
    end
  
     factory :user_admin, class: User do
      email { "johnfive@example.com" }
      password { "kosjksjd123235@" }
      password_confirmation { "kosjksjd123235@" }
      role {:admin}
    end

    factory :user_buyer, class: User do
      email { "johnfour@example.com" }
      password { "kosjksjd123235@" }
      password_confirmation { "kosjksjd123235@" }
      role {:buyer}
    end
  end