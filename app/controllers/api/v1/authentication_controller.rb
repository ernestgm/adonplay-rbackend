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
    end
  end
end