class FollowersController < ApplicationController
  def index
    @followers = @good_night_service.get_self_followers

    render json: { data: @followers }
  end

  def create
    @good_night_service.follow_user(users_params[:id])

    render json: { message: "User followed" }
  end

  def destroy
    @good_night_service.unfollow_user(params.expect(:id))

    render json: { message: "User unfollowed" }
  end

  private

  def users_params
    params.expect(user: [ :id ])
  end
end
