class AddPartsToDocumentParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :document_participants, :parts, :integer, default: 1
  end
end
