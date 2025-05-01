require 'rails_helper'

RSpec.describe GoodNightService do
  let(:user) { create(:user) }
  let(:follower_user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }

  before do
    GoodNightService.new(user.id)
  end

  describe '.get_user' do
    it 'returns the user when found' do
      expect(GoodNightService.get_user(user.id)).to eq(user)
    end

    it 'returns nil when user is not found' do
      expect(GoodNightService.get_user(-1)).to be_nil
    end
  end

  describe '.get_self_followers' do
    it 'returns the followers of the user' do
      create(:user_follower, user: user, follower: follower_user)
      expect(GoodNightService.get_self_followers).to include(follower_user)
    end
  end

  describe '.clock_in' do
    it 'creates a new sleep record' do
      expect { GoodNightService.clock_in }.to change { SleepRecord.count }.by(1)
    end

    it 'updates the last record if duration is zero' do
      sleep_record.update(duration_seconds: 0)
      GoodNightService.clock_in
      expect(sleep_record.reload.duration_seconds).not_to eq(0)
    end
  end

  describe '.clock_out' do
    it 'updates the sleep record duration' do
      record = create(:sleep_record, user: user, duration_seconds: 0, clock_in: Time.now - 1.hour)
      expect { GoodNightService.clock_out(record.id) }.to change { record.reload.duration_seconds }.from(0)
    end

    it 'raises an error if the record does not belong to the user' do
      other_user = create(:user)
      other_record = create(:sleep_record, user: other_user)
      expect { GoodNightService.clock_out(other_record.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.get_self_sleep_records' do
    it 'returns paginated sleep records' do
      create_list(:sleep_record, 3, user: user)
      result = GoodNightService.get_self_sleep_records(1, 2)
      expect(result[:data].size).to eq(2)
      expect(result[:meta][:total_count]).to eq(3)
    end
  end

  describe '.follow_user' do
    it 'follows a user' do
      expect { GoodNightService.follow_user(follower_user.id) }.to change { UserFollower.count }.by(1)
    end

    it 'raises an error if trying to follow oneself' do
      expect { GoodNightService.follow_user(user.id) }.to raise_error(GoodNightService::CannotFollowYourselfError)
    end

    it 'raises an error if already followed' do
      create(:user_follower, user: user, follower: follower_user)
      expect { GoodNightService.follow_user(follower_user.id) }.to raise_error(GoodNightService::AlreadyFollowedError)
    end

    it 'raises an error if user not found' do
      expect { GoodNightService.follow_user(-1) }.to raise_error(GoodNightService::NotFoundError)
    end
  end

  describe '.unfollow_user' do
    it 'unfollows a user' do
      create(:user_follower, user: user, follower: follower_user)
      expect { GoodNightService.unfollow_user(follower_user.id) }.to change { UserFollower.count }.by(-1)
    end

    it 'raises an error if not followed' do
      expect { GoodNightService.unfollow_user(follower_user.id) }.to raise_error(GoodNightService::NotFollowedError)
    end
  end

  describe '.get_user_followers_sleep_records' do
    it 'returns sleep records of followers' do
      create(:user_follower, user: user, follower: follower_user)
      create(:sleep_record, user: follower_user, duration_seconds: 3600)
      records = GoodNightService.get_user_followers_sleep_records
      expect(records.size).to eq(1)
    end

    it 'includes self sleep records if specified' do
      create(:sleep_record, user: user, duration_seconds: 3600)
      records = GoodNightService.get_user_followers_sleep_records(true)
      expect(records.size).to eq(1)
    end
  end
end
