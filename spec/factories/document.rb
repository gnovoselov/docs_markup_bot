FactoryBot.define do
    factory :document do
        chat
        document_id { Faker::Internet.uuid }
        status { :active }

        trait :inactive do
            status { :inactive }
        end

        trait :done do
            status { :done }
        end
    end
end
