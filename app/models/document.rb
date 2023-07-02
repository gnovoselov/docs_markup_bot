# == Schema Information
#
# Table name: documents
#
#  id                   :integer          not null, primary key
#  max_participants     :integer
#  optimal_participants :integer
#  status               :integer          default("inactive")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  chat_id              :integer
#  document_id          :string
#
class Document < ApplicationRecord
  belongs_to :chat
  has_many :document_participants, dependent: :delete_all
  has_many :participants, through: :document_participants
  has_many :fuckups, dependent: :nullify
  has_many :fuckedup_participants, through: :fuckups, source: :participant
  has_many :shares, dependent: :delete_all

  enum status: %i[inactive pending active done]

  validates_uniqueness_of :document_id, scope: :chat_id

  def url
    "https://docs.google.com/document/d/#{document_id}/edit"
  end
end
