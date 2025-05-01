require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:followers).class_name('UserFollower').with_foreign_key('user_id') }
    it { should have_many(:following).class_name('UserFollower').with_foreign_key('follower') }
    it { should have_many(:sleep_records) }
  end

  describe '#followers' do
    let(:user) { create(:user) }
    let(:follower_user) { create(:user) }
    let!(:user_follower) { create(:user_follower, user: user, follower: follower_user) }

    it 'returns the list of followers' do
      expect(user.followers).to include(follower_user)
    end

    it 'does not include non-followers' do
      non_follower = create(:user)
      expect(user.followers).not_to include(non_follower)
    end
  end
end
