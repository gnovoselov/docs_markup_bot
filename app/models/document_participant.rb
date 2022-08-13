class DocumentParticipant < ApplicationRecord
  belongs_to :document
  belongs_to :participant

  enum status: %i[inactive active]

  validates_uniqueness_of :participant_id, scope: :document_id
end
