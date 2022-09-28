class Chat < ApplicationRecord
  has_many :documents, dependent: :delete_all
  has_many :waiters

  def inactivate_all!
    documents.active.update_all(status: :done)
    documents.pending.update_all(status: :done)
  end
end
