class AddPlayerIdToNote < ActiveRecord::Migration
  def change
    add_column :notes, :player_id, :integer
  end
end
