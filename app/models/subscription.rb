class Subscription < ApplicationRecord
  belongs_to :participant
  belongs_to :chat
end
