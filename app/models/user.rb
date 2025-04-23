class User < ApplicationRecord
    has_many :followers, class_name: 'UserFollower', foreign_key: 'user_id'
    has_many :following, class_name: 'UserFollower', foreign_key: 'follower'

    def followers
        UserFollower.where(user_id: self.id).left_joins(:follower).map do |follower|
            follower.follower
        end
    end
end
