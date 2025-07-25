module Api
  module V1
    class AuthenticationController < ApplicationController
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

      # DELETE /api/v1/logout
      def logout
        # In a JWT-based authentication system, the token is typically invalidated on the client side
        # Here we just return a success message
        render json: { message: 'Logged out successfully' }, status: :ok
      end
    end
  end
end