class CreateDocumentParticipants < ActiveRecord::Migration[7.0]
  def change
    create_table :document_participants do |t|
      t.integer :document_id
      t.integer :participant_id
      t.integer :status, default: 1

      t.timestamps
    end
  end
end
