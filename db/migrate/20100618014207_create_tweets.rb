class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.string :status_id
      t.text :payload

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
