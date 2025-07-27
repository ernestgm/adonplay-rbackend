module Api
  module V1
    class QrsController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_qr, only: [:show, :update]
      before_action -> { entity_owner_or_admin_only!(@qr) }, only: [:show, :update]
      before_action :verify_business_ownership, only: [:create, :update]
      
      # GET /api/v1/qrs
      def index
        @qrs = scope_to_owner(Qr)
        render json: @qrs.map { |qr| QrSerializer.new(qr).as_json }, status: :ok
      end
      
      # GET /api/v1/qrs/1
      def show
        render json: QrSerializer.new(@qr).as_json, status: :ok
      end
      
      # POST /api/v1/qrs
      def create
        @qr = Qr.new(qr_params)
        
        if @qr.save
          render json: QrSerializer.new(@qr).as_json, status: :created
        else
          render json: { errors: format_errors(@qr) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/qrs/1
      def update
        if @qr.update(qr_params)
          render json: QrSerializer.new(@qr).as_json, status: :ok
        else
          render json: { errors: format_errors(@qr) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/qrs
      def destroy
        if params[:ids].present?
          # Bulk QR deletion
          qr_ids = params[:ids].map(&:to_i)
          
          # Scope to QRs owned by current user if not admin
          qrs = scope_to_owner(Qr.where(id: qr_ids))
          
          deleted_count = qrs.destroy_all.count
          
          render json: { 
            message: "#{deleted_count} QRs deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No QR IDs provided' }, status: :bad_request
        end
      end
      
      private
      
      def set_qr
        @qr = Qr.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'QR not found' }, status: :not_found
      end
      
      def qr_params
        # Support direct JSON format without nesting
        params.permit(:name, :info, :position, :business_id)
      end
      
      def verify_business_ownership
        business_id = params[:business_id]
        return if current_user.role == 'admin' || !business_id
        
        business = Business.find_by(id: business_id)
        unless business && business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only create QRs for your own businesses' }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Business not found' }, status: :not_found
      end
    end
  end
end