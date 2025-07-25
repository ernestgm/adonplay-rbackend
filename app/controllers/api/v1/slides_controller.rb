module Api
  module V1
    class SlidesController < ApplicationController
      include Authenticable
      include Authorizable
      include ErrorFormatter
      
      before_action :authenticate_request
      before_action :set_slide, only: [:show, :update, :destroy]
      before_action -> { entity_owner_or_admin_only!(@slide) }, only: [:show, :update, :destroy]
      before_action :verify_business_ownership, only: [:create, :update]
      
      # GET /api/v1/slides
      def index
        @slides = scope_to_owner(Slide)
        render json: @slides.map { |slide| SlideSerializer.new(slide).as_json }, status: :ok
      end
      
      # GET /api/v1/slides/1
      def show
        render json: SlideSerializer.new(@slide).as_json, status: :ok
      end
      
      # POST /api/v1/slides
      def create
        @slide = Slide.new(slide_params)
        
        if @slide.save
          render json: SlideSerializer.new(@slide).as_json, status: :created
        else
          render json: { errors: format_errors(@slide) }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/slides/1
      def update
        if @slide.update(slide_params)
          render json: SlideSerializer.new(@slide).as_json, status: :ok
        else
          render json: { errors: format_errors(@slide) }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/slides
      def destroy
        if params[:id]
          # Single slide deletion
          @slide.destroy
          render json: { message: 'Slide deleted successfully' }, status: :ok
        elsif params[:ids].present?
          # Bulk slide deletion
          slide_ids = params[:ids].map(&:to_i)
          
          # Scope to slides owned by current user if not admin
          slides = scope_to_owner(Slide.where(id: slide_ids))
          
          deleted_count = slides.destroy_all.count
          
          render json: { 
            message: "#{deleted_count} slides deleted successfully",
            deleted_count: deleted_count
          }, status: :ok
        else
          render json: { error: 'No slide IDs provided' }, status: :bad_request
        end
      end
      
      private
      
      def set_slide
        @slide = Slide.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Slide not found' }, status: :not_found
      end
      
      def slide_params
        # Support direct JSON format without nesting
        params.permit(:name, :business_id)
      end
      
      def verify_business_ownership
        business_id = params[:business_id]
        return if current_user.role == 'admin' || !business_id
        
        business = Business.find_by(id: business_id)
        unless business && business.owner_id == current_user.id
          render json: { error: 'Unauthorized: You can only create slides for your own businesses' }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Business not found' }, status: :not_found
      end
    end
  end
end