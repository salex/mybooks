class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :acct
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.string :subdomain
      t.string :domain

      t.timestamps
    end
  end
end
