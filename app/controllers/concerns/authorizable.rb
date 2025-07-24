module Authorizable
  extend ActiveSupport::Concern

  # Check if the current user is an admin
  def admin_only!
    unless current_user&.role == 'admin'
      render json: { error: 'Unauthorized: Admin access required' }, status: :forbidden
    end
  end

  # Check if the current user is the owner of the resource or an admin
  def owner_or_admin_only!(resource_user_id)
    unless current_user&.id == resource_user_id || current_user&.role == 'admin'
      render json: { error: 'Unauthorized: Owner or admin access required' }, status: :forbidden
    end
  end
end