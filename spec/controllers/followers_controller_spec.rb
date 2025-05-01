require 'rails_helper'

RSpec.describe FollowersController, type: :controller do
  let(:user) { create(:user, id: 1) }
  let(:another_user) { create(:user, id: 2) }
  let(:user_follower) { create(:user_follower, user: user, follower: another_user) }

  before do
    request.headers['X-User-Id'] = user.id
    allow(GoodNightService).to receive(:get_self_followers).and_return([ user_follower ])
    allow(GoodNightService).to receive(:follow_user).and_return(true)
    allow(GoodNightService).to receive(:unfollow_user).and_return(true)
  end

  describe 'GET #index' do
    it 'returns a success response with followers' do
      get :index
      expect(response).to be_successful
      expect(JSON.parse(response.body)['data'].first['follower']['id']).to eq(another_user.id)
    end

    it 'returns unauthorized if user is not authenticated' do
      request.headers['X-User-Id'] = nil
      get :index
      puts response.status
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'follows a user and returns a success message' do
        post :create, params: { user: { id: another_user.id } }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['message']).to eq('User followed')
      end
    end

    context 'with invalid params' do
      it 'returns a not found response when user is not found' do
        allow(GoodNightService).to receive(:follow_user).and_raise(GoodNightService::NotFoundError)
        post :create, params: { user: { id: -1 } }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error when trying to follow oneself' do
        allow(GoodNightService).to receive(:follow_user).and_raise(GoodNightService::CannotFollowYourselfError)
        post :create, params: { user: { id: user.id } }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error when already followed' do
        allow(GoodNightService).to receive(:follow_user).and_raise(GoodNightService::AlreadyFollowedError)
        post :create, params: { user: { id: another_user.id } }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      it 'unfollows a user and returns a success message' do
        delete :destroy, params: { id: another_user.id }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['message']).to eq('User unfollowed')
      end
    end

    context 'with invalid params' do
      it 'returns a not found response when user is not followed' do
        allow(GoodNightService).to receive(:unfollow_user).and_raise(GoodNightService::NotFollowedError)
        delete :destroy, params: { id: -1 }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
