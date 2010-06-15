class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :user_id, :primary => true
      t.string :token
      t.string :secret
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
