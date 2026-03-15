class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :client, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.string :name
      t.string :account_type
      t.string :code
      t.string :description
      t.boolean :placeholder
      t.integer :parent_id
      t.integer :level

      t.timestamps
    end
  end
end
