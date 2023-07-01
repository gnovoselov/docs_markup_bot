FactoryBot.define do
    factory :document do
        chat
        document_id { Faker::Internet.uuid }
    end
end
