class AddUsernameToVote < ActiveRecord::Migration
  def self.up
    add_column :votes, :username, :string
  end

  def self.down
    remove_column :votes, :username
  end
end
