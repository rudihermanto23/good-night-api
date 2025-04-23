class UsersController < ApplicationController
  before_action :initialize_services

  # GET /users/1
  def show
    @user = @good_night_service.get_user(params.expect(:id))

    unless @user
        return not_found_response(:user)
    end

    render json: { data: @user }
  end
end
