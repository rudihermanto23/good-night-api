module GoodNightService
    class << self
        def new(user)
            @user = user
            self
        end

        def get_user(id)
            begin
                User.find(id)
            rescue ActiveRecord::RecordNotFound
                nil
            end
        end

        def get_self_followers
            @user.followers
        end

        def clock_in
            # TODO: Implement clock in
        end

        def clock_out(sleep_record_id)
            # TODO: Implement clock out
        end

        def get_self_sleep_records
            # TODO: Implement get self sleep records
        end

        def follow_user(user_id)
            if @user.id == user_id
                raise GoodNightService::CannotFollowYourselfError
            end

            follower = UserFollower.where(user_id: @user.id, follower: user_id).first

            if follower
                raise GoodNightService::AlreadyFollowedError
            end

            user = get_user(user_id)

            if user.nil?
                raise GoodNightService::UserNotFoundError
            end

            UserFollower.create(user_id: @user.id, follower: user_id, created_at: Time.now)
        end

        def unfollow_user(user_id)
            follower = UserFollower.where(user_id: @user.id, follower: user_id).first

            if follower.nil?
                raise GoodNightService::NotFollowedError
            end

            follower.destroy
        end

        def get_user_followers_sleep_records
            # TODO: Implement get user followers sleep records
        end
    end

    class ApplicationError < StandardError
        attr_reader :code, :message
    
        def initialize(code, message)
            @code = code
            @message = message
        end
    end
    
    class CannotFollowYourselfError < ApplicationError
        def initialize
            super(400001, 'Cannot follow yourself')
        end
    end

    class AlreadyFollowedError < ApplicationError
        def initialize
            super(400002, 'Already followed')
        end
    end

    class NotFollowedError < ApplicationError
        def initialize
            super(400003, 'Not followed')
        end
    end
    
    class UserNotFoundError < ApplicationError
        def initialize
            super(404001, 'User not found')
        end
    end
end
