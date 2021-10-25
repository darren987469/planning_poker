# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.string :name
      t.string :code, index: { unique: true }
      t.string :status, default: 'not_started'

      t.timestamps
    end
  end
end
