class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name
      t.date :date_from
      t.date :date_to
      t.text :settings

      t.timestamps
    end
  end
end
