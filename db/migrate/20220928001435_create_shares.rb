class CreateShares < ActiveRecord::Migration[7.0]
  def change
    create_table :shares do |t|
      t.integer :document_id
      t.integer :participant_id
      t.integer :part, default: 0

      t.timestamps
    end
  end
end
