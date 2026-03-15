class AddJsonToAudits < ActiveRecord::Migration[8.0]
  def change
    add_column :audits, :json, :text
  end
end
