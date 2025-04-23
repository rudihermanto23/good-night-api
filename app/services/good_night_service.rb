class GoodNightService
    def initialize(user)
        @user = user
    end

    def get_user(id)
        begin
            User.find(id)
        rescue ActiveRecord::RecordNotFound
            nil
        end
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
        # TODO: Implement follow user
    end

    def unfollow_user(user_id)
        # TODO: Implement unfollow user
    end

    def get_user_followers_sleep_records
        # TODO: Implement get user followers sleep records
    end
end
