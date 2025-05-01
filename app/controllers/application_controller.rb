class ApplicationController < ActionController::API
    before_action :initialize_services

    rescue_from StandardError do |exception|
        case exception
        when ActiveRecord::RecordNotFound
            not_found_response
        else
            application_error_response(exception)
        end
    end

    protected

    def initialize_services
        user_id = request.headers["X-User-Id"]

        @good_night_service ||= GoodNightService.new(user_id)
    end

    def unauthorized_response
        render json: { code: 401001, message: "Unauthorized" }, status: :unauthorized
    end

    def not_found_response
        render json: { code: 404001, message: "Not found" }, status: :not_found
    end

    def application_error_response(error)
        if error.is_a?(GoodNightService::ApplicationError)
            case error
            when GoodNightService::UnauthorizedError
                unauthorized_response
            when GoodNightService::NotFoundError
                not_found_response
            else
                render json: { code: error.code, message: error.message }, status: :bad_request and return
            end
        else
            Rails.logger.error("error: #{error.inspect}, class: #{error.class}, stack:\n#{error.backtrace.join("\n")}")
            render json: { code: 500001, message: "Internal Server Error" }, status: :internal_server_error
        end
    end
end
