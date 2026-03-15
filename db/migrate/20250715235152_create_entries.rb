class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.references :client, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.string :numb
      t.date :post_date
      t.string :description
      t.string :fit_id
      t.integer :lock_version

      t.timestamps
    end
    add_index :entries, :post_date
    add_index :entries, :description
  end
end
