module Api
  module V1
    class AuthenticationController < ApplicationController
      include Authenticable
      include ErrorFormatter

      before_action :authenticate_request, only: [:activate_device, :logout]
      before_action :set_login_code, only: [:activate_device]
      before_action :set_login_device_code, only: [:login_device]

      # POST /api/v1/login
      def login
        @user = User.find_by(email: params[:email], enabled: true)

        return render json: { error: 'User Disabled' }, status: :unauthorized unless @user
        
        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode({user_id: @user.id})
          render json: { token: token, user: UserSerializer.new(@user).as_json }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # POST /api/v1/activate_device
      def activate_device
        return render json: { error: 'Invalid Code' }, status: :forbidden unless @login_code

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
          target_device_id = @login_code.device_id # Obtén el app_id de la aplicación a la que quieres enviar la acción
          action_data = {
            type: "ejecute_login", # Tipo de acción para que el cliente la interprete
            payload: {
              user_id: user_id,
              device_id: @login_code.device_id,
              code: @login_code.code
            }
          }

          # Envía la acción al stream de esa aplicación específica
          LoginActionsChannel.broadcast_to(
            target_device_id, # El identificador de la aplicación
            action_data
          )

          render json: {login_code: LoginCodeSerializer.new(@login_code).as_json, message: "Device Activated"}, status: :ok
        else
          render json: { error: format_errors(@login_code) }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/login_device
      def login_device
        return render json: { error: 'Invalid User' }, status: :unauthorized unless @user_login_code

        @user = User.find(@user_login_code.user_id)

        if @user
          @device = Device.find_by(device_id: @user_login_code.device_id)

          if @device.nil?
            @device = Device.new(
              name: @user_login_code.device_id,
              users_id: @user_login_code.user_id,
              device_id: @user_login_code.device_id,
            )

            return render json: { error: format_errors(@device) }, status: :unprocessable_entity unless @device.save
          else
            if @device.users_id != @user.id
              return render json: { error: format_errors(@device) }, status: :unprocessable_entity unless @device.update(
                users_id: @user_login_code.user_id,
                qr_id: nil,
                marquee_id: nil,
                slide_id: nil
              )
            end
          end

          return render json: { error: format_errors(@user_login_code) }, status: :unprocessable_entity unless @user_login_code.delete

          token = JsonWebToken.encode({user_id: @user.id}, nil)
          render json: { token: token, user: UserSerializer.new(@user).as_json }, status: :ok
        else
          render json: { error: 'Invalid Authentication User' }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout
      def logout
        target_device_id = '1cf892da6a0d9e8f' # Obtén el app_id de la aplicación a la que quieres enviar la acción
        action_data = {
          type: "change_user", # Tipo de acción para que el cliente la interprete
          payload: {
            user_id: 7,
            device_id: target_device_id,
          }
        }

        # Envía la acción al stream de esa aplicación específica
        ChangeUserActionsChannel.broadcast_to(
          target_device_id, # El identificador de la aplicación
          action_data
        )

        render json: { message: 'Logged out successfully' }, status: :ok
      end

      def login_code_params
        # Aquí lista solo los parámetros que pueden cambiarse, excepto user_id
        params.permit(:code, :device_id, :user_id)
      end

      def set_login_code
        @login_code = LoginCode.find_by(code: params[:code])
      end

      def set_login_device_code
        @user_login_code = LoginCode.find_by(code: params[:code], device_id: params[:device_id], user_id: params[:user_id])
      end
    end
  end
end