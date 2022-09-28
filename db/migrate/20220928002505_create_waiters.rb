class CreateWaiters < ActiveRecord::Migration[7.0]
  def change
    create_table :waiters do |t|
      t.integer :chat_id
      t.integer :participant_id
      t.integer :parts

      t.timestamps
    end
  end
end
