# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_05_22_000300) do
  create_table "activation_logs", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.integer "groq_key_id"
    t.string "device_identifier", null: false
    t.string "ip_address"
    t.datetime "activated_at", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_activation_logs_on_action"
    t.index ["activated_at"], name: "index_activation_logs_on_activated_at"
    t.index ["customer_id"], name: "index_activation_logs_on_customer_id"
    t.index ["groq_key_id"], name: "index_activation_logs_on_groq_key_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "license_key", null: false
    t.string "full_name", null: false
    t.string "business_name"
    t.string "email", null: false
    t.string "phone_number", null: false
    t.text "address"
    t.string "device_identifier"
    t.integer "groq_key_id"
    t.string "plan_type", default: "monthly", null: false
    t.date "subscription_start_date", null: false
    t.date "subscription_expiry_date", null: false
    t.string "status", default: "active", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email"
    t.index ["groq_key_id"], name: "index_customers_on_groq_key_id"
    t.index ["license_key"], name: "index_customers_on_license_key", unique: true
    t.index ["phone_number"], name: "index_customers_on_phone_number"
    t.index ["status"], name: "index_customers_on_status"
  end

  create_table "groq_keys", force: :cascade do |t|
    t.text "api_key", null: false
    t.boolean "is_assigned", default: false, null: false
    t.integer "assigned_customer_id"
    t.datetime "assigned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_customer_id"], name: "index_groq_keys_on_assigned_customer_id"
    t.index ["is_assigned"], name: "index_groq_keys_on_is_assigned"
  end

  add_foreign_key "activation_logs", "customers"
  add_foreign_key "activation_logs", "groq_keys"
  add_foreign_key "customers", "groq_keys"
  add_foreign_key "groq_keys", "customers", column: "assigned_customer_id"
end
