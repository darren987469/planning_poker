class CreateVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :votes do |t|
      t.bigint :game_id
      t.references :user
      t.string :value

      t.timestamps
    end

    add_index :votes, %i[game_id user_id], unique: true
  end
end
