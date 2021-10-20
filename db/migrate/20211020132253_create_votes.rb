class CreateVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :votes do |t|
      t.bigint :game_id
      t.references :user
      t.integer :value

      t.timestamps
    end

    add_index :votes, [:game_id, :user_id], unique: true
  end
end
