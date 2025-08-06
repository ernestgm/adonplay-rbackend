module Api
  module V1
    class MarqueesController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_marquee, only: [:show, :update]
      before_action -> { entity_owner_or_admin_only!(@marquee) }, only: [:show, :update]
      before_action :verify_business_ownership, only: [:create, :update]
      
      # GET /api/v1/marquees
      def index
        @marquees = scope_to_owner(Marquee)
        render json: @marquees.map { |marquee| MarqueeSerializer.new(marquee).as_json }, status: :ok
      end

      # GET /api/v1/marquees_by_user
      def index_by_user
        @marquees = scope_by_owner(Marquee, params[:user_id])
        render json: @marquees.map { |marquee| MarqueeSerializer.new(marquee).as_json }, status: :ok
      end
      
      # GET /api/v1/marquees/1
      def show
        render json: MarqueeSerializer.new(@marquee).as_json, status: :ok
      end
      
      # POST /api/v1/marquees
      def create
        @marquee = Marquee.new(marquee_params)
        
        if @marquee.save
          render json: MarqueeSerializer.new(@marquee).as_json, status: :created
        else
          render json: { errors: format_errors(@marquee) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/marquees/1
      def update
        if @marquee.update(marquee_params)
          render json: MarqueeSerializer.new(@marquee).as_json, status: :ok
        else
          render json: { errors: format_errors(@marquee) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/marquees
      def destroy
        if params[:ids].present?
          # Bulk marquee deletion
          marquee_ids = params[:ids].map(&:to_i)
          
          # Scope to marquees owned by current user if not admin
          marquees = scope_to_owner(Marquee.where(id: marquee_ids))
          
          deleted_count = marquees.destroy_all.count
          
          render json: { 
            message: "#{deleted_count} marquees deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No marquee IDs provided' }, status: :bad_request
        end
      end
      
      private
      
      def set_marquee
        @marquee = Marquee.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Marquee not found' }, status: :not_found
      end
      
      def marquee_params
        # Support direct JSON format without nesting
        params.permit(:name, :message, :background_color, :text_color, :business_id)
      end
      
      def verify_business_ownership
        business_id = params[:business_id]
        return if current_user.role == 'admin' || !business_id
        
        business = Business.find_by(id: business_id)
        unless business && business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only create marquees for your own businesses' }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Business not found' }, status: :not_found
      end
    end
  end
end