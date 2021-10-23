describe '/users', type: :request do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:valid_attributes) { { name: 'name' }  }
  let(:invalid_attributes) { { name: nil } }

  describe 'GET /new' do
    subject { get new_user_url }

    it 'renders a successful response' do
      subject
      expect(response).to be_successful
    end

    context 'when there is a user session' do
      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return({ current_user_id: user.id })
      end

      it 'redirects to new game url' do
        subject
        expect(response).to redirect_to new_game_url
      end
    end
  end

  describe 'POST /create' do
    subject { post users_url, params: { user: params } }

    context 'with valid parameters' do
      let(:params) { { name: 'name' } }

      it 'creates a new User' do
        expect { subject }.to change(User, :count).by(1)
      end

      it 'sets current_user_id to the session' do
        subject
        expect(session[:current_user_id]).to eq User.last.id
      end

      it 'redirects to new game url' do
        subject
        expect(response).to redirect_to new_game_url
      end

      context 'when there is a game_code in the session' do
        before do
          allow_any_instance_of(ActionDispatch::Request)
            .to receive(:session).and_return({ game_code: game.code })
        end

        it 'creates a vote to associate the user and the game' do
          expect { subject }.to change(Vote, :count).by(1)
        end

        it 'redirects the the game url' do
          subject
          expect(response).to redirect_to game_url(game.code)
        end
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
