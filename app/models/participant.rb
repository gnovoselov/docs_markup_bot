class Participant < ApplicationRecord
  has_many :document_participants
  has_many :documents, through: :document_participants
  has_many :shares, dependent: :delete_all
  has_many :waiters, dependent: :delete_all
  has_many :subscriptions, dependent: :delete_all

  def full_name
    name = [first_name, last_name].reject(&:blank?).join(' ')
    return name if name.present?

    username
  end
end
