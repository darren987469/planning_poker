describe PokerGameService do
  let(:user) { create(:user) }
  let(:game) { create(:game, status: 'voting') }
  let(:vote_value) { 1 }
  let(:vote) { create(:vote, game: game, user: user, value: vote_value) }
  let(:service) { described_class.new(event) }

  describe '#run' do
    subject { service.run }

    context 'update_vote event' do
      let(:event) do
        {
          type: 'update_vote',
          params: {
            game: { id: game.id },
            vote: { id: vote.id, value: '3' },
            user: { id: user.id }
          }
        }
      end

      it 'updates the vote value' do
        expect { subject }.to change { vote.reload.value }.from('1').to('3')
      end

      it { expect(subject).to eq true }

      context 'invalid game status' do
        before { game.update_columns(status: 'not_started') }

        it 'sets errors to the service' do
          subject
          expect(service.errors.full_messages).to eq ['invalid game status']
        end

        it { expect(subject).to eq false }
      end
    end

    context 'update_game event' do
      let(:event) do
        {
          type: 'update_game',
          params: {
            game: { id: game.id, status: new_game_status }
          }
        }
      end

      before { game.update_columns(status: game_status) }

      context 'game status not_started -> voting' do
        let(:vote_value) { nil } # game not_started, no vote value
        let(:game_status) { 'not_started' }
        let(:new_game_status) { 'voting' }

        it 'updates game status' do
          expect { subject }.to change {
            game.reload.status
          }.from(game_status).to(new_game_status)
        end
      end

      context 'game status voting -> voting_ended' do
        let(:game_status) { 'voting' }
        let(:new_game_status) { 'voting_ended' }

        it 'updates game status' do
          expect { subject }.to change {
            game.reload.status
          }.from(game_status).to(new_game_status)
        end
      end

      context 'game status voting_ended -> voting' do
        let(:game_status) { 'voting_ended' }
        let(:new_game_status) { 'voting' }

        it 'updates game status' do
          expect { subject }.to change {
            game.reload.status
          }.from(game_status).to(new_game_status)
        end

        it 'resets all vote values' do
          expect { subject }.to change { vote.reload.value }.from('1').to(nil)
        end
      end

      context 'invalid game status update' do
        let(:game_status) { 'voting' }
        let(:new_game_status) { 'not_started' }

        it 'sets errors to the service' do
          subject
          expect(service.errors.full_messages).to eq ['invalid game status change']
        end
      end
    end
  end
end
