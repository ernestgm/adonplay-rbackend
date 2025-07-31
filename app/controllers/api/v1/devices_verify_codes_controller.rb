module Api
  module V1
    class DevicesVerifyCodesController < ApplicationController
      include Deniable
      include ErrorFormatter

      before_action :verify_request, only: [:create_login_code]
      before_action -> { check_device_id!(params[:device_id]) }, only: [:create]
      before_action -> { check_valid_player!(params[:device_id], params[:code]) }, only: [:create_login_code]

      # POST /api/v1/device_verify_code
      def create
        token = JsonWebToken.encode(device_id: device_params[:device_id], exp: 0)

        @device_verify_code = DevicesVerifyCodes.find_by(device_id: params[:device_id])
        if @device_verify_code != nil
          render json: { device: DeviceVerifyCodeSerializer.new(@device_verify_code).as_json,  token: token }, status: :created
        end

        permit_params = device_params
        code = DeviceValidator.generate_luhn
        permit_params[:code] = code
        @device_verify_code = DevicesVerifyCodes.new(permit_params)
        
        if @device_verify_code.save
          render json: { device: DeviceVerifyCodeSerializer.new(@device_verify_code).as_json,  token: token }, status: :created
        else
          render json: { errors: format_errors(@device_verify_code) }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/create_login_code
      def create_login_code
        code = rand(100_000..999_999)
        permit_params = device_player_params
        permit_params[:code] = code

        @login_code = LoginCode.new(permit_params)
        if @login_code.save
          render json: DeviceVerifyCodeSerializer.new(@login_code).as_json , status: :created
        else
          render json: { errors: format_errors(@login_code) }, status: :unprocessable_entity
        end
      end


      
      private
      
      def device_params
        # Support direct JSON format without nesting
        params.permit(:device_id)
      end

      def device_player_params
        # Support direct JSON format without nesting
        params.permit(:device_id, :code)
      end
    end
  end
end