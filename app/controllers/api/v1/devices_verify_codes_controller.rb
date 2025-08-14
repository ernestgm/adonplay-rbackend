module Api
  module V1
    class DevicesVerifyCodesController < ApplicationController
      include Authenticable
      include Deniable
      include ErrorFormatter

      before_action :authenticate_request, only: [ :index, :update ]
      before_action :verify_request, only: [:create_login_code]
      before_action -> { check_device_id!(params[:device_id]) }, only: [:create]
      before_action -> { check_valid_player!(params[:device_id], params[:code]) }, only: [:create_login_code]
      before_action :set_login_code, only: [:create_login_code, :update]

      def index
        if current_user.role == 'admin'
          @devices_verify_codes = DevicesVerifyCodes.all
        end

        render json: @devices_verify_codes.map { |device| DeviceVerifyCodeSerializer.new(device).as_json }, status: :ok
      end

      # POST /api/v1/device_verify_code
      def create
        @device_verify_code = DevicesVerifyCodes.find_by(device_id: params[:device_id])
        if @device_verify_code != nil
          if @device_verify_code.registered
            token = JsonWebToken.encode({device_id: device_params[:device_id]}, nil)
            render json: { device: DeviceVerifyCodeSerializer.new(@device_verify_code).as_json,  token: token }, status: :ok
          else
            render json: { device: DeviceVerifyCodeSerializer.new(@device_verify_code).as_json }, status: :ok
          end
          return
        end

        permit_params = device_params
        code = DeviceValidator.generate_luhn
        permit_params[:code] = code
        @device_verify_code = DevicesVerifyCodes.new(permit_params)
        
        if @device_verify_code.save
          render json: { device: DeviceVerifyCodeSerializer.new(@device_verify_code).as_json }, status: :created
        else
          render json: { errors: format_errors(@device_verify_code) }, status: :unprocessable_entity
        end
      end

      def update
        @device_verify_code = DevicesVerifyCodes.find(params[:id])
        if @device_verify_code.update(:registered => params[:registered])
          render json: { message: "Persmission Updated" }, status: :ok
        else
          render json: { errors: format_errors(@device) }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/create_login_code
      def create_login_code
        @device_verify_code = DevicesVerifyCodes.find_by(device_id: params[:device_id])
        if @device_verify_code != nil
          @device = Device.find_by(device_id: params[:device_id])
          if @device != nil && @device.users != nil && @device.users.enabled
            @user = @device.users
            token = JsonWebToken.encode({user_id: @user.id}, nil)
            render json: { token: token, user: UserSerializer.new(@user).as_json }, status: :ok
            return
          end
        end

        if @login_code != nil
          render json: LoginCodeSerializer.new(@login_code).as_json , status: :created
          return
        end

        code = rand(100_000..999_999)
        permit_params = device_player_params
        permit_params[:code] = code

        @login_code = LoginCode.new(permit_params)
        if @login_code.save
          render json: LoginCodeSerializer.new(@login_code).as_json , status: :created
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

      def set_login_code
        @login_code = LoginCode.find_by(device_id: params[:device_id])
      end
    end
  end
end