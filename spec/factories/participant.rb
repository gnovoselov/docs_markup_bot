FactoryBot.define do
    factory :participant do
        first_name { Faker::Name.first_name }
        last_name { Faker::Name.last_name }
        username { Faker::Internet.username }
        
        trait :admin do
            username { TELEGRAM_ADMINS.sample }
        end
    end
end
