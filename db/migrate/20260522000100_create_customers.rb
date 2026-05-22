class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :license_key, null: false
      t.string :full_name, null: false
      t.string :business_name
      t.string :email, null: false
      t.string :phone_number, null: false
      t.text :address
      t.string :device_identifier
      t.references :groq_key
      t.string :plan_type, null: false, default: "monthly"
      t.date :subscription_start_date, null: false
      t.date :subscription_expiry_date, null: false
      t.string :status, null: false, default: "active"
      t.text :notes

      t.timestamps
    end

    add_index :customers, :license_key, unique: true
    add_index :customers, :email
    add_index :customers, :phone_number
    add_index :customers, :status
  end
end
