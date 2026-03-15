class CreateBankStatements < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_statements do |t|
      t.references :client, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.date :statement_date
      t.integer :beginning_balance
      t.integer :ending_balance
      t.text :summary
      t.date :reconciled_date
      t.text :json

      t.timestamps
    end
  end
end
