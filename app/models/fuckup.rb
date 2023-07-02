# == Schema Information
#
# Table name: fuckups
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  document_id    :integer
#  participant_id :integer
#
class Fuckup < ApplicationRecord
  belongs_to :document
  belongs_to :participant

  validates_uniqueness_of :participant_id, scope: :document_id
end
