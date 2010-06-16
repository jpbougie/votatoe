class AddColumnToPoll < ActiveRecord::Migration
  def self.up
    add_column :polls, :last_seen_id, :string
  end

  def self.down
    remove_column :polls, :last_seen_id
  end
end
