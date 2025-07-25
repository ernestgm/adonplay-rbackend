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

  # Check if the current user is the owner of the business or an admin
  def business_owner_or_admin_only!(business)
    unless current_user&.id == business.owner_id || current_user&.role == 'admin'
      render json: { error: 'Unauthorized: Business owner or admin access required' }, status: :forbidden
    end
  end

  # Check if the current user is the owner of the entity through its business or an admin
  def entity_owner_or_admin_only!(entity)
    unless current_user&.id == entity.business.owner_id || current_user&.role == 'admin'
      render json: { error: 'Unauthorized: Business owner or admin access required' }, status: :forbidden
    end
  end

  # Scope entities to those owned by the current user (if owner) or all (if admin)
  def scope_to_owner(relation)
    if current_user.role == 'admin'
      relation.all
    else
      relation.joins(:business).where(businesses: { owner_id: current_user.id })
    end
  end

  # Scope businesses to those owned by the current user (if owner) or all (if admin)
  def scope_businesses_to_owner(relation)
    if current_user.role == 'admin'
      relation.all
    else
      relation.where(owner_id: current_user.id)
    end
  end
end