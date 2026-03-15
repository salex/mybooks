class CreateAudits < ActiveRecord::Migration[8.0]
  def change
    create_table :audits do |t|
      t.references :client, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.date :date_from
      t.integer :balance
      t.integer :outstanding
      t.text :settings

      t.timestamps
    end
  end
end
