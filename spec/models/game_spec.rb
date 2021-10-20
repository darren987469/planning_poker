describe Game, type: :model do
  it 'generates code if not set' do
    game = create(:game)
    expect(game.code).to be_present
  end

  it 'cannot creates two games with same code' do
    create(:game, code: 'code')
    expect { create(:game, code: 'code') }.to raise_error ActiveRecord::RecordNotUnique
  end
end
