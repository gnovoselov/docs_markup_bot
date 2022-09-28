class Chat < ApplicationRecord
  has_many :documents, dependent: :delete_all
  has_many :participants, through: :documents
  has_many :subscriptions, dependent: :delete_all
  has_many :waiters, dependent: :delete_all

  def inactivate_all!
    documents.active.update_all(status: :done)
    documents.pending.update_all(status: :done)
  end
end
