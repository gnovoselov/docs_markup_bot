class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :document_id
      t.integer :status, default: 0
      t.integer :chat_id
      t.integer :max_participants

      t.timestamps
    end
  end
end
