class ApplicationController < ActionController::API
    protected

    def set_current_user
        # Since we do not implement authentication, we will use the user_id from the request header for simplicity
        user_id = request.headers['X-User-Id']

        unless user_id
            unauthorized_response
        end

        @current_user = User.find(user_id)
    end

    def initialize_services
        begin
            set_current_user

            @good_night_service ||= GoodNightService.new(@current_user)
        rescue ActiveRecord::RecordNotFound
            unauthorized_response
        end
    end

    def unauthorized_response
        render json: { code: 401001, message: 'Unauthorized' }, status: :unauthorized
    end

    def not_found_response(entity)
        render json: { code: 404001, message: "#{entity} not found" }, status: :not_found
    end

    def application_error_response(error)
        if error.is_a?(GoodNightService::ApplicationError)
            render json: { code: error.code, message: error.message }, status: :bad_request
        else
            render json: { code: 500001, message: 'Internal Server Error' }, status: :internal_server_error
        end
    end
end
