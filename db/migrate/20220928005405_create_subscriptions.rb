class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.integer :participant_id
      t.integer :chat_id

      t.timestamps
    end
  end
end
