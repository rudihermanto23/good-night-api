require 'rails_helper'

RSpec.describe UserFollower, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:follower).class_name('User').with_foreign_key('follower') }
  end
end
