class CreateUserFollowers < ActiveRecord::Migration[8.0]
  def change
    create_table :user_followers, primary_key: [:user_id, :follower] do |t|
      t.integer :user_id
      t.integer :follower
      t.datetime :created_at
    end

    add_index :user_followers, :user_id
    add_index :user_followers, :follower
  end
end
