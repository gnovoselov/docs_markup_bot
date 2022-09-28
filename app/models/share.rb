class Share < ApplicationRecord
  belongs_to :participant
  belongs_to :document
end
