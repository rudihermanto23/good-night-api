class FollowersController < ApplicationController
  before_action :initialize_services

  # GET /sleep_records
  def index
    @followers = @good_night_service.get_self_followers

    render json: { data: @followers }
  end

  # POST /followers
  def create
    begin
      @good_night_service.follow_user(users_params[:id])
    rescue ActiveRecord::RecordNotFound
      return not_found_response(:user)
    rescue GoodNightService::ApplicationError => e
      return application_error_response(e)
    end

    render json: { message: 'User followed' }
  end

  # DELETE /followers/1
  def destroy
    @good_night_service.unfollow_user(params.expect(:id))

    render json: { message: 'User unfollowed' }
  end

  private

  def users_params
    params.expect(user: [:id])
  end
end
