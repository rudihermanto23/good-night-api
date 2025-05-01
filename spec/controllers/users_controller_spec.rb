require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user, id: 1) }
  let(:valid_attributes) { { id: user.id } }
  let(:invalid_attributes) { { id: 2 } }

  before do
    allow(GoodNightService).to receive(:get_user).and_return(user)
  end

  describe 'GET #show' do
    context 'with valid params' do
      it 'returns a success response' do
        request.headers['X-User-Id'] = user.id.to_s
        get :show, params: valid_attributes
        expect(response).to be_successful
        expect(JSON.parse(response.body)['data']['id']).to eq(user.id)
      end
    end

    context 'with invalid params' do
      it 'returns a not found response' do
        allow(GoodNightService).to receive(:get_user).and_return(nil)
        request.headers['X-User-Id'] = user.id.to_s
        get :show, params: invalid_attributes
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
