# == Schema Information
#
# Table name: waiters
#
#  id             :integer          not null, primary key
#  parts          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  chat_id        :integer
#  participant_id :integer
#
class Waiter < ApplicationRecord
  belongs_to :participant
  belongs_to :chat
end
