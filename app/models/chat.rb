class Chat < ApplicationRecord
  has_many :documents

  def inactivate_all!
    documents.active.update_all(status: :done)
    documents.pending.update_all(status: :done)
  end
end
