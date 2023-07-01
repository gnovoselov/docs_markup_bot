# == Schema Information
#
# Table name: shares
#
#  id             :integer          not null, primary key
#  part           :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  document_id    :integer
#  participant_id :integer
#
class Share < ApplicationRecord
  belongs_to :participant
  belongs_to :document
end
