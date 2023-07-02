FactoryBot.define do
    factory :document_participant do
        document
        participant
        status { :active }

        trait :inactive do
            status { :inactive }
        end
    end
end
