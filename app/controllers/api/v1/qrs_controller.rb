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
      after_action :notify_changes, only: [:update]
      
      # GET /api/v1/qrs
      def index
        @qrs = scope_to_owner(Qr)
        render json: @qrs.map { |qr| QrSerializer.new(qr).as_json }, status: :ok
      end

      # GET /api/v1/qrs_by_user
      def index_by_user
        @qrs = scope_by_owner(Qr, params[:user_id])
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

          qrs.each do |qr|
            self.broadcast_notify_change(qr)
          end
          
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
      def broadcast_notify_change(qr)
        on_devices = @qr.devices.pluck(:device_id)
        on_slide_medias = Device
                            .joins(slide: :slide_medias)
                            .where(slide_medias: { qr_id: qr.id })
                            .pluck(:device_id)
        all_devices = (on_devices + on_slide_medias).uniq

        all_devices.each do |device_id|
          action_data = {
            type: "ejecute_data_change", # Tipo de acción para que el cliente la interprete
            payload: {
              updated_at: qr.updated_at,
              msg: "Slide Media Notify Changes"
            }
          }
          ChangeDevicesActionsChannel.broadcast_to(
            device_id, # El identificador de la aplicación
            action_data
          )
        end
      end
      def notify_changes
        return unless @qr&.persisted?
        self.broadcast_notify_change(@qr)
      end
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