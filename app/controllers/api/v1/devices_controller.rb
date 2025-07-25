module Api
  module V1
    class DevicesController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_device, only: [:show, :update, :destroy]
      before_action :verify_device_ownership, only: [:show, :update, :destroy]
      before_action :verify_associations_ownership, only: [:create, :update]
      
      # GET /api/v1/devices
      def index
        if current_user.role == 'admin'
          @devices = Device.all
        else
          # For owner, get devices associated with slides, marquees, or QRs that belong to businesses they own
          @devices = Device.left_joins(slide: :business, marquee: :business, qr: :business)
                          .where('slides.business_id IN (SELECT id FROM businesses WHERE owner_id = ?) OR 
                                 marquees.business_id IN (SELECT id FROM businesses WHERE owner_id = ?) OR 
                                 qrs.business_id IN (SELECT id FROM businesses WHERE owner_id = ?)', 
                                 current_user.id, current_user.id, current_user.id)
                          .distinct
        end
        
        render json: @devices.map { |device| DeviceSerializer.new(device).as_json }, status: :ok
      end
      
      # GET /api/v1/devices/1
      def show
        render json: DeviceSerializer.new(@device).as_json, status: :ok
      end
      
      # POST /api/v1/devices
      def create
        @device = Device.new(device_params)
        
        if @device.save
          render json: DeviceSerializer.new(@device).as_json, status: :created
        else
          render json: { errors: format_errors(@device) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/devices/1
      def update
        if @device.update(device_params)
          render json: DeviceSerializer.new(@device).as_json, status: :ok
        else
          render json: { errors: format_errors(@device) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/devices
      def destroy
        if params[:id]
          # Single device deletion
          @device.destroy
          render json: { message: 'Device deleted successfully' }, status: :ok
        elsif params[:ids].present?
          # Bulk device deletion
          device_ids = params[:ids].map(&:to_i)
          
          # Scope to devices owned by current user if not admin
          if current_user.role == 'admin'
            devices = Device.where(id: device_ids)
          else
            # Get devices associated with slides, marquees, or QRs that belong to businesses owned by the current user
            devices = Device.left_joins(slide: :business, marquee: :business, qr: :business)
                           .where(id: device_ids)
                           .where('slides.business_id IN (SELECT id FROM businesses WHERE owner_id = ?) OR 
                                  marquees.business_id IN (SELECT id FROM businesses WHERE owner_id = ?) OR 
                                  qrs.business_id IN (SELECT id FROM businesses WHERE owner_id = ?)', 
                                  current_user.id, current_user.id, current_user.id)
                           .distinct
          end
          
          deleted_count = devices.destroy_all.count
          
          render json: { 
            message: "#{deleted_count} devices deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No device IDs provided' }, status: :bad_request
        end
      end
      
      private
      
      def set_device
        @device = Device.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Device not found' }, status: :not_found
      end
      
      def device_params
        # Support direct JSON format without nesting
        params.permit(:name, :device_id, :qr_id, :marquee_id, :slide_id)
      end
      
      def verify_device_ownership
        return if current_user.role == 'admin'
        
        # Check if the device is associated with a slide, marquee, or QR that belongs to a business owned by the current user
        is_owner = false
        
        # Check slide association
        if @device.slide && @device.slide.business && @device.slide.business.owner_id == current_user.id
          is_owner = true
        end
        
        # Check marquee association
        if !is_owner && @device.marquee && @device.marquee.business && @device.marquee.business.owner_id == current_user.id
          is_owner = true
        end
        
        # Check QR association
        if !is_owner && @device.qr && @device.qr.business && @device.qr.business.owner_id == current_user.id
          is_owner = true
        end
        
        unless is_owner
          render json: { error: 'Unauthorized: You can only access devices associated with your own businesses' }, status: :forbidden
        end
      end
      
      def verify_associations_ownership
        return if current_user.role == 'admin'
        
        # Verify slide ownership if provided
        slide_id = params[:slide_id]
        if slide_id.present?
          slide = Slide.find_by(id: slide_id)
          unless slide && slide.business.owner_id == current_user.id
            render json: { error: 'Unauthorized: You can only use slides from your own businesses' }, status: :forbidden
            return
          end
        end
        
        # Verify marquee ownership if provided
        marquee_id = params[:marquee_id]
        if marquee_id.present?
          marquee = Marquee.find_by(id: marquee_id)
          unless marquee && marquee.business.owner_id == current_user.id
            render json: { error: 'Unauthorized: You can only use marquees from your own businesses' }, status: :forbidden
            return
          end
        end
        
        # Verify QR ownership if provided
        qr_id = params[:qr_id]
        if qr_id.present?
          qr = Qr.find_by(id: qr_id)
          unless qr && qr.business.owner_id == current_user.id
            render json: { error: 'Unauthorized: You can only use QRs from your own businesses' }, status: :forbidden
            return
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Slide, Marquee, or QR not found' }, status: :not_found
      end
    end
  end
end