class DropBankTransactions < ActiveRecord::Migration[8.0]
  def change
    drop_table :bank_transactions
  end
end
