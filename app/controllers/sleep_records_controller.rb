class SleepRecordsController < ApplicationController
  before_action :initialize_services

  # GET /sleep_records
  def index
    @records = @good_night_service.get_self_sleep_records(sleep_record_params[:page].to_i, sleep_record_params[:per_page].to_i)

    render json: @records
  end

  # POST /sleep_records
  def create
    begin
      @record = @good_night_service.clock_in
    rescue GoodNightService::ApplicationError => e
      return application_error_response(e)
    end

    render json: { data: @record }
  end

  # PATCH/PUT /sleep_records/1
  def update
    begin
      @record = @good_night_service.clock_out(params[:id])
    rescue ActiveRecord::RecordNotFound
      return not_found_response(:sleep_record)
    rescue GoodNightService::ApplicationError => e
      return application_error_response(e)
    end

    render json: { data: @record }
  end

  # GET /sleep_records/following
  def following
    @records = @good_night_service.get_user_followers_sleep_records(parse_boolean(following_params[:include_self]))

    render json: { data: @records }
  end

  private 

  def sleep_record_params
    params.permit(:page, :per_page).tap do |whitelisted|
      whitelisted[:page] ||= 1
      whitelisted[:per_page] ||= 10
    end
  end

  def following_params
    params.permit(:include_self).tap do |whitelisted|
      whitelisted[:include_self] ||= false
    end
  end

  def parse_boolean(value)
    return false if value.nil?

    return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)

    value.to_s.downcase == 'true' || value.to_i == 1
  end
end
