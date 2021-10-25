# frozen_string_literal: true

describe Game, type: :model do
  it 'generates code if not set' do
    game = create(:game)
    expect(game.code).to be_present
  end

  it 'cannot creates two games with same code' do
    create(:game, code: 'code')
    expect { create(:game, code: 'code') }.to raise_error ActiveRecord::RecordNotUnique
  end

  it 'returns error when invalid status change' do
    game = build(:game, status: 'voting_ended')
    expect(game).to be_invalid
    expect(game.errors.full_messages).to eq ['invalid game status change']
  end
end
