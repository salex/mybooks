class RenameUserEmail < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :email
    remove_column :users, :email_address
    # add_index :users, :email_address, unique: true

  end
end
