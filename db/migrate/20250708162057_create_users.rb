class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    # add_column :users, :email_address, :string, null: false
    # add_column :users, :email_address, null: false

    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false  
      t.string :username
      t.string :roles
      t.integer :default_book
      t.integer :client_id
      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
