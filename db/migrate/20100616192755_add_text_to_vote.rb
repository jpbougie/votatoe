class AddTextToVote < ActiveRecord::Migration
  def self.up
    add_column :votes, :text, :string
  end

  def self.down
    remove_column :votes, :text
  end
end
