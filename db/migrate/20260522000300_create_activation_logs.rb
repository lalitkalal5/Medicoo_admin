class CreateActivationLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :activation_logs do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :groq_key, foreign_key: true
      t.string :device_identifier, null: false
      t.string :ip_address
      t.datetime :activated_at, null: false
      t.string :action, null: false

      t.timestamps
    end

    add_index :activation_logs, :activated_at
    add_index :activation_logs, :action
  end
end
