class ChangeStatusIdToInteger < ActiveRecord::Migration
  def self.up
    change_column :users, :twitter_id, :integer
    change_column :polls, :status_id, :integer
    change_column :votes, :status_id, :integer
    change_column :tweets, :status_id, :integer
  end

  def self.down
    change_column :users, :twitter_id, :string
    change_column :polls, :status_id, :string
    change_column :votes, :status_id, :string
    change_column :tweets, :status_id, :string
  end
end
