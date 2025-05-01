class UsersController < ApplicationController
  def show
    @user = @good_night_service.get_user(params.expect(:id))

    unless @user
        return not_found_response
    end

    render json: { data: @user }
  end
end
