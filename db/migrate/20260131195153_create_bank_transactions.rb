class CreateBankTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_transactions do |t|
      t.references :client, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :split_id
      t.date :post_date
      t.string :category
      t.string :description
      t.float :amount

      t.timestamps
    end
  end
end
