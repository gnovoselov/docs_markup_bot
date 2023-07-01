# == Schema Information
#
# Table name: document_participants
#
#  id             :integer          not null, primary key
#  parts          :integer          default(1)
#  status         :integer          default("active")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  document_id    :integer
#  participant_id :integer
#
class DocumentParticipant < ApplicationRecord
  belongs_to :document
  belongs_to :participant

  enum status: %i[inactive active]

  validates_uniqueness_of :participant_id, scope: :document_id
end
