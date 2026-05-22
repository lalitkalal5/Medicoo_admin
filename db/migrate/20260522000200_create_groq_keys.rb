class CreateGroqKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :groq_keys do |t|
      t.text :api_key, null: false
      t.boolean :is_assigned, null: false, default: false
      t.references :assigned_customer, foreign_key: { to_table: :customers }
      t.datetime :assigned_at

      t.timestamps
    end

    add_index :groq_keys, :is_assigned
  end
end
