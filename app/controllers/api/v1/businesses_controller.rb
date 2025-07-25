module Api
  module V1
    class BusinessesController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_business, only: [:show, :update]
      before_action :admin_only!, only: [:destroy]
      before_action -> { business_owner_or_admin_only!(@business) }, only: [:show, :update]
      
      # GET /api/v1/businesses
      def index
        @businesses = scope_businesses_to_owner(Business)
        render json: @businesses.map { |business| BusinessSerializer.new(business).as_json }, status: :ok
      end
      
      # GET /api/v1/businesses/1
      def show
        render json: BusinessSerializer.new(@business).as_json, status: :ok
      end
      
      # POST /api/v1/businesses
      def create
        @business = Business.new(business_params)
        
        # Set owner_id to current user if not admin
        if current_user.role != 'admin' && !@business.owner_id
          @business.owner_id = current_user.id
        end
        
        if @business.save
          render json: BusinessSerializer.new(@business).as_json, status: :created
        else
          render json: { errors: format_errors(@business) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/businesses/1
      def update
        if @business.update(business_params)
          render json: BusinessSerializer.new(@business).as_json, status: :ok
        else
          render json: { errors: format_errors(@business) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/businesses
      def destroy
        if params[:ids].present?
          # Bulk business deletion
          business_ids = params[:ids].map(&:to_i)
          
          # Scope to businesses owned by current user if not admin
          businesses = scope_businesses_to_owner(Business.where(id: business_ids))
          
          deleted_count = businesses.destroy_all.count
          
          render json: { 
            message: "#{deleted_count} businesses deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No business IDs provided' }, status: :bad_request
        end
      end
      
      private
      
      def set_business
        @business = Business.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Business not found' }, status: :not_found
      end
      
      def business_params
        # Support direct JSON format without nesting
        params.permit(:name, :description, :owner_id)
      end
    end
  end
end