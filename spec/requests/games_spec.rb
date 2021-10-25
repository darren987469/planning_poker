describe '/games', type: :request do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:valid_attributes) { { name: 'name' } }
  let(:invalid_attributes) { { name: nil } }

  describe 'GET /index' do
    let!(:game) { create(:game) }

    subject { get games_url }

    it 'renders a successful response' do
      subject
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    subject { get game_url(game.code) }

    context 'when there is no user session' do
      it 'redirects to new user url' do
        subject
        expect(response).to redirect_to new_user_url
      end
    end

    context 'when there is a user session' do
      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return({ current_user_id: user.id })
      end

      it 'sets game_code in the session' do
        subject
        expect(session[:game_code]).to eq game.code
      end

      it 'renders a successful response' do
        subject
        expect(response).to be_successful
      end

      it 'creates a vote to associate the user and the game' do
        expect { subject }.to change(Vote, :count).by(1)
        expect(Vote.last).to have_attributes(
          user_id: user.id,
          game_id: game.id
        )
      end

      it 'broadcasts to notify there is a new user join the game' do
        expect do
          subject
        end.to have_broadcasted_to("game_#{game.id}")
      end

      context 'the user already has association with the game' do
        let!(:vote) { create(:vote, game: game, user: user) }

        it 'won\'t create a vote to associate the user and the game' do
          expect { subject }.to change(Vote, :count).by(0)
        end
      end
    end
  end

  describe 'GET /new' do
    subject { get new_game_url }

    context 'when there is no user session' do
      it 'redirects to new user url' do
        subject
        expect(response).to redirect_to new_user_url
      end
    end

    context 'when there is a user session' do
      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return({ current_user_id: user.id })
      end

      it 'renders a successful response' do
        subject
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /create' do
    let(:params) { { name: 'name' } }

    subject { post games_url, params: { game: params } }

    context 'when there is no user session' do
      it 'redirects to new user url' do
        subject
        expect(response).to redirect_to new_user_url
      end
    end

    context 'when there is a user session' do
      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return({ current_user_id: user.id })
      end

      context 'with valid parameters' do
        let(:params) { { name: 'name', code: 'code' } }

        it 'creates a new Game' do
          expect { subject }.to change(Game, :count).by(1)
        end

        it 'redirects to game url' do
          subject
          expect(response).to redirect_to game_url(Game.last.code)
        end
      end

      context 'with invalid parameters' do
        let(:params) { { name: nil } }

        it 'does not create a new User' do
          expect { subject }.to change(User, :count).by(0)
        end

        it 'renders unprocessable_entity response' do
          subject
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end
  end
end
