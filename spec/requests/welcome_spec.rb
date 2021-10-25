# frozen_string_literal: true

describe '/', type: :request do
  describe 'GET /' do
    context 'when there is a user session' do
      let!(:user) { create(:user) }

      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return({ current_user_id: user.id })
      end

      it 'redirects to new game url' do
        get root_url
        expect(response).to redirect_to(new_game_url)
      end
    end

    context 'when there is no user session' do
      it 'redirects to new user url' do
        get root_url
        expect(response).to redirect_to(new_user_url)
      end
    end
  end
end
