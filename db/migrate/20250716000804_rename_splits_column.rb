class RenameSplitsColumn < ActiveRecord::Migration[8.0]
  def change
    change_table :splits do |t|
      t.rename :reconcile, :reconcile_date
    end
  end

end
