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

ActiveRecord::Schema[8.0].define(version: 2026_01_31_195153) do
  create_table "accounts", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "book_id", null: false
    t.string "name"
    t.string "account_type"
    t.string "code"
    t.string "description"
    t.boolean "placeholder"
    t.integer "parent_id"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "contra"
    t.index ["book_id"], name: "index_accounts_on_book_id"
    t.index ["client_id"], name: "index_accounts_on_client_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "book_id", null: false
    t.date "date_from"
    t.integer "balance"
    t.integer "outstanding"
    t.text "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "json"
    t.index ["book_id"], name: "index_audits_on_book_id"
    t.index ["client_id"], name: "index_audits_on_client_id"
  end

  create_table "bank_statements", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "book_id", null: false
    t.date "statement_date"
    t.integer "beginning_balance"
    t.integer "ending_balance"
    t.text "summary"
    t.date "reconciled_date"
    t.text "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_bank_statements_on_book_id"
    t.index ["client_id"], name: "index_bank_statements_on_client_id"
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "book_id", null: false
    t.integer "split_id"
    t.date "post_date"
    t.string "category"
    t.string "description"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_bank_transactions_on_book_id"
    t.index ["client_id"], name: "index_bank_transactions_on_client_id"
  end

  create_table "books", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "name"
    t.date "date_from"
    t.date "date_to"
    t.text "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_books_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "acct"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "subdomain"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "book_id", null: false
    t.string "numb"
    t.date "post_date"
    t.string "description"
    t.string "fit_id"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_entries_on_book_id"
    t.index ["client_id"], name: "index_entries_on_client_id"
    t.index ["description"], name: "index_entries_on_description"
    t.index ["post_date"], name: "index_entries_on_post_date"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "splits", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "account_id", null: false
    t.integer "entry_id", null: false
    t.string "memo"
    t.string "action"
    t.string "reconcile_state"
    t.date "reconcile_date"
    t.integer "amount"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_splits_on_account_id"
    t.index ["client_id"], name: "index_splits_on_client_id"
    t.index ["entry_id"], name: "index_splits_on_entry_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "password_digest", null: false
    t.string "username"
    t.string "roles"
    t.integer "default_book"
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_address"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "accounts", "books"
  add_foreign_key "accounts", "clients"
  add_foreign_key "audits", "books"
  add_foreign_key "audits", "clients"
  add_foreign_key "bank_statements", "books"
  add_foreign_key "bank_statements", "clients"
  add_foreign_key "bank_transactions", "books"
  add_foreign_key "bank_transactions", "clients"
  add_foreign_key "books", "clients"
  add_foreign_key "entries", "books"
  add_foreign_key "entries", "clients"
  add_foreign_key "sessions", "users"
  add_foreign_key "splits", "accounts"
  add_foreign_key "splits", "clients"
  add_foreign_key "splits", "entries"
end
