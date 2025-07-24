module Api
  module V1
    class UsersController < ApplicationController
      include Authenticable
      include Authorizable
      
      skip_before_action :authenticate_request, only: [:create]
      before_action :set_user, only: [:show, :update, :destroy]
      before_action :admin_only!, only: [:index]
      before_action -> { owner_or_admin_only!(@user.id) }, only: [:destroy]
      before_action :authorize_update, only: [:update]

      # GET /api/v1/users
      def index
        @users = User.where.not(id: current_user.id)
        render json: @users.map { |user| UserSerializer.new(user).as_json }, status: :ok
      end

      # GET /api/v1/users/1
      def show
        render json: UserSerializer.new(@user).as_json, status: :ok
      end

      # POST /api/v1/users
      def create
        @user = User.new(user_params)

        if @user.save
          render json: UserSerializer.new(@user).as_json, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/1
      def update
        if @user.update(user_params)
          render json: UserSerializer.new(@user).as_json, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users
      def destroy
        if params[:ids].blank?
          render json: { error: 'No user IDs provided' }, status: :bad_request
          return
        end

        user_ids = params[:ids].map(&:to_i)
        
        if user_ids.include?(current_user.id)
          render json: { error: 'You cannot delete your own account' }, status: :forbidden
          return
        end

        deleted_count = User.where(id: user_ids).destroy_all.count
        
        render json: { 
          message: "#{deleted_count} users deleted successfully",
          deleted_count: deleted_count
        }, status: :ok
      end
      
      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def user_params
        params.require(:user).permit(:name, :email, :role, :password, :password_confirmation)
      end
      
      # Custom authorization for update action
      # Owners can only edit their own profile, admins can edit any profile
      def authorize_update
        if current_user.role == 'owner' && current_user.id != @user.id
          render json: { error: 'Unauthorized: You can only edit your own profile' }, status: :forbidden
        end
      end
    end
  end
end