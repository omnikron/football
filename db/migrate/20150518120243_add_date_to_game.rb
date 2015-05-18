class AddDateToGame < ActiveRecord::Migration
  def change
    add_column :games, :date, :date
  end
end
