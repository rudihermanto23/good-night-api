require 'rails_helper'

RSpec.describe SleepRecordsController, type: :controller do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }
  let(:valid_attributes) { { id: sleep_record.id } }
  let(:invalid_attributes) { { id: -1 } }

  before do
    request.headers['X-User-Id'] = user.id.to_s
    allow(GoodNightService).to receive(:get_self_sleep_records).and_return({ data: [ sleep_record ], meta: { page: 1, per_page: 10, total_pages: 1, total_count: 1 } })
    allow(GoodNightService).to receive(:clock_in).and_return(sleep_record)
    allow(GoodNightService).to receive(:clock_out).and_return(sleep_record)
    allow(GoodNightService).to receive(:get_user_followers_sleep_records).and_return([ sleep_record ])
  end

  describe 'GET #index' do
    it 'returns a success response with sleep records' do
      get :index, params: { page: 1, per_page: 10 }
      expect(response).to be_successful
      expect(JSON.parse(response.body)['data'].first['id']).to eq(sleep_record.id)
    end
  end

  describe 'POST #create' do
    it 'creates a new sleep record and returns a success response' do
      post :create
      expect(response).to be_successful
      expect(JSON.parse(response.body)['data']['id']).to eq(sleep_record.id)
    end

    it 'returns an application error response' do
      allow(GoodNightService).to receive(:clock_in).and_raise(StandardError.new("Error"))
      post :create
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid params' do
      it 'updates the sleep record and returns a success response' do
        patch :update, params: valid_attributes
        expect(response).to be_successful
        expect(JSON.parse(response.body)['data']['id']).to eq(sleep_record.id)
      end
    end

    context 'with invalid params' do
      it 'returns a not found response' do
        allow(GoodNightService).to receive(:clock_out).and_raise(ActiveRecord::RecordNotFound)
        patch :update, params: invalid_attributes
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an application error response' do
        allow(GoodNightService).to receive(:clock_out).and_raise(StandardError.new("Error"))
        patch :update, params: valid_attributes
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  describe 'GET #following' do
    it 'returns a success response with followers sleep records' do
      get :following, params: { include_self: true }
      expect(response).to be_successful
      expect(JSON.parse(response.body)['data'].first['id']).to eq(sleep_record.id)
    end

    it 'returns a success response without self sleep records' do
      get :following, params: { include_self: false }
      expect(response).to be_successful
      expect(JSON.parse(response.body)['data'].first['id']).to eq(sleep_record.id)
    end
  end
end
