class AddOptiomalParticipantsToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :optimal_participants, :integer
  end
end
