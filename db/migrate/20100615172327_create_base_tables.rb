class CreateBaseTables < ActiveRecord::Migration
  def self.up
    create_table :polls, :force => true do |t|
      t.integer :user_id
      t.string :text
      t.string :status_id
      t.string :type
      
      t.timestamps
    end
    
    add_index :polls, :status_id, :unique => true
    
    create_table :users, :force => true do |t|
      t.string :username
      t.string :twitter_id
      t.timestamps
    end
    
    add_index :users, :twitter_id, :unique => true
    
    create_table :votes, :force => true do |t|
      t.integer :poll_id
      t.string :status_id
      t.string :author
      t.string :choice
      t.string :location
      t.string :agent
      
      t.timestamps
    end
    
    add_index :votes, :status_id, :unique => true
    add_index :votes, [:poll_id, :author], :unique => true
  end

  def self.down
    remove_index :votes, :column => [:poll_id, :author]
    remove_index :votes, :column => :status_id
    remove_index :users, :column => :twitter_id
    remove_index :polls, :column => :status_id
    drop_table :vote
    drop_table :users
    drop_table :polls
  end
end
