class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.integer :user_id
      t.datetime :clock_in
      t.integer :duration_seconds
    end

    add_index :sleep_records, :user_id
    add_index :sleep_records, [:user_id, :clock_in]
    add_index :sleep_records, :duration_seconds
  end
end
