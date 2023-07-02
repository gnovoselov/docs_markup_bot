class CreateFuckups < ActiveRecord::Migration[7.0]
  def change
    create_table :fuckups do |t|
      t.integer :document_id
      t.integer :participant_id

      t.timestamps
    end
  end
end
