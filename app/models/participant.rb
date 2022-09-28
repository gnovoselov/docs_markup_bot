class Participant < ApplicationRecord
  has_many :document_participants
  has_many :documents, through: :document_participants
  has_many :shares
  has_many :waiters

  def full_name
    name = [first_name, last_name].reject(&:blank?).join(' ')
    return name if name.present?

    username
  end
end
