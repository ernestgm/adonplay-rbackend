module Api
  module V1
    class AuthenticationController < ApplicationController
      include Authenticable
      include ErrorFormatter

      before_action :authenticate_request, only: [:activate_device]
      before_action :set_login_code, only: [:activate_device]
      # POST /api/v1/login
      def login
        @user = User.find_by(email: params[:email])
        
        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: @user.id)
          render json: { token: token, user: UserSerializer.new(@user).as_json }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # POST /api/v1/activate_device
      def activate_device
        return render json: { error: 'Invalid Code' }, status: :unauthorized unless @login_code

        @user = current_user

        # Creamos un hash solo con los parámetros permitidos, sin user_id por ahora
        permitted = login_code_params

        user_id = if @user.role == 'admin' && params[:user_id].present?
                    # Verificamos que el user_id enviado exista en la base de datos
                    user = User.find_by(id: params[:user_id])
                    user ? user.id : @user.id
                  else
                    @user.id
                  end

        permitted[:user_id] = user_id

        if @login_code.update(permitted)
          render json: LoginCodeSerializer.new(@login_code).as_json, status: :ok
        else
          render json: { error: format_errors(@login_code) }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/login_device
      def login_device
        @user = User.find_by(email: params[:email])

        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: @user.id)
          render json: { token: token, user: UserSerializer.new(@user).as_json }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout
      def logout
        # In a JWT-based authentication system, the token is typically invalidated on the client side
        # Here we just return a success message
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      def login_code_params
        # Aquí lista solo los parámetros que pueden cambiarse, excepto user_id
        params.permit(:code, :device_id)
      end

      def set_login_code
        @login_code = LoginCode.find_by(code: params[:code], device_id: params[:device_id])
      end
    end
  end
end