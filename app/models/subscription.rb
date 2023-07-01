# == Schema Information
#
# Table name: subscriptions
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  chat_id        :integer
#  participant_id :integer
#
class Subscription < ApplicationRecord
  belongs_to :participant
  belongs_to :chat
end
