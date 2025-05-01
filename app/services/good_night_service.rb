module GoodNightService
    class << self
        def new(user_id)
            raise UnauthorizedError unless user_id

            @user = User.find(user_id)

            raise UnauthorizedError unless @user

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
            last_record = @user.sleep_records.order(clock_in: :desc).first

            if last_record && last_record.duration_seconds == 0
                last_record.update(duration_seconds: (Time.now - last_record.clock_in).abs)
            end

            SleepRecord.create(user_id: @user.id, clock_in: Time.now, duration_seconds: 0)
        end

        def clock_out(sleep_record_id)
            record = SleepRecord.find(sleep_record_id)

            if record.user_id != @user.id
                raise ActiveRecord::RecordNotFound
            end

            record.update(duration_seconds: (Time.now - record.clock_in).abs)

            record.reload
        end

        def get_self_sleep_records(page, per_page)
            count = @user.sleep_records.count
            records = @user.sleep_records.order(clock_in: :desc).limit(per_page).offset((page - 1) * per_page)

            {
                data: records,
                meta: {
                    page: page,
                    per_page: per_page,
                    total_pages: (count.to_f / per_page).ceil,
                    total_count: count
                }
            }
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
                raise GoodNightService::NotFoundError
            end

            UserFollower.create(user_id: @user.id, follower: user, created_at: Time.now)
        end

        def unfollow_user(user_id)
            follower = UserFollower.where(user_id: @user.id, follower: user_id).first

            if follower.nil?
                raise GoodNightService::NotFollowedError
            end

            follower.destroy
        end

        def get_user_followers_sleep_records(include_self = false)
            followers = @user.followers

            if include_self
                followers << @user
            end

            SleepRecord.where(user_id: followers.map(&:id)).where("clock_in > ?", 7.days.ago).where("duration_seconds > ?", 0).order(duration_seconds: :desc).map do |record|
                {
                    id: record.id,
                    duration_seconds: record.duration_seconds,
                    clock_in: record.clock_in,
                    user: {
                        id: record.user.id,
                        name: record.user.name
                    }
                }
            end
        end
    end

    class ApplicationError < StandardError
        attr_accessor :code, :message

        def initialize(code, message)
            @code = code
            @message = message
        end
    end

    class UnauthorizedError < ApplicationError
        def initialize
            super(401001, "Unauthorized")
        end
    end

    class NotFoundError < ApplicationError
        def initialize
            super(404001, "Not found")
        end
    end

    class CannotFollowYourselfError < ApplicationError
        def initialize
            super(400001, "Cannot follow yourself")
        end
    end

    class AlreadyFollowedError < ApplicationError
        def initialize
            super(400002, "Already followed")
        end
    end

    class NotFollowedError < ApplicationError
        def initialize
            super(400003, "Not followed")
        end
    end
end
