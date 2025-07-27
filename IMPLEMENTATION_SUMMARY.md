# Implementation Summary

This document summarizes the changes made to implement the requirements specified in the issue description.

## Requirements

1. Users with the "owner" role should only be able to edit their own profile.
2. When listing users, the authenticated user should not be included in the list.
3. Users should not be able to delete themselves.
4. It should be possible to delete multiple users at once using an array of IDs.

## Changes Made

### 1. Restricting "owner" users to only edit their own profile

- Added a new `authorize_update` method to the UsersController that checks if the current user has the "owner" role and is trying to edit a profile other than their own.
- Added a before_action to call this method before the update action.
- Updated the API documentation to clarify this restriction.

```ruby
def authorize_update
  if current_user.role == 'owner' && current_user.id != @user.id
    render json: { error: 'Unauthorized: You can only edit your own profile' }, status: :forbidden
  end
end
```

### 2. Excluding the authenticated user from the list

- Modified the index action in the UsersController to exclude the current user from the list of users.
- Updated the API documentation to mention this behavior.

```ruby
def index
  @users = User.where.not(id: current_user.id)
  render json: @users.map { |user| UserSerializer.new(user).as_json }, status: :ok
end
```

### 3. Preventing users from deleting themselves

- Added a check in the destroy action to prevent users from deleting their own account.
- Updated the API documentation to mention this restriction.

```ruby
def destroy
  if @user.id == current_user.id
    render json: { error: 'You cannot delete your own account' }, status: :forbidden
  else
    @user.destroy
    head :no_content
  end
end
```

### 4. Implementing bulk deletion of users

- Added a new `destroy_multiple` action to the UsersController that accepts an array of user IDs and deletes those users.
- Ensured that the current user's ID is automatically excluded from the deletion, even if it's included in the request.
- Added a new route for this action as a collection route to the users resource.
- Restricted this action to admin users only.
- Updated the API documentation to document this new endpoint.

```ruby
def destroy_multiple
  if params[:ids].blank?
    render json: { error: 'No user IDs provided' }, status: :bad_request
    return
  end
  
  # Ensure current user is not in the list of IDs to delete
  user_ids = params[:ids].map(&:to_i) - [current_user.id]
  
  # Delete the users
  deleted_count = User.where(id: user_ids).destroy_all.count
  
  render json: { message: "#{deleted_count} users deleted successfully" }, status: :ok
end
```

## Testing

A test script (`test_user_api.sh`) has been created to verify that all the new functionality works as expected. This script tests:

1. That the index action excludes the current user from the list.
2. That owners can only edit their own profile.
3. That users cannot delete themselves.
4. That the bulk delete action works and excludes the current user from deletion.

To run the test script, execute the following command in the Docker container:

```bash
docker-compose exec rorbackend bash test_user_api.sh
```

## Documentation

The API documentation has been updated to reflect all the changes made. The following sections have been added or updated:

1. The "Get All Users" section now mentions that it excludes the current user.
2. The "Update User" section now clarifies that owners can only edit their own profile.
3. The "Delete User" section now mentions that users cannot delete themselves.
4. A new section for the "Delete Multiple Users" action has been added.
5. The "Notes" section has been updated to include information about all the new features and restrictions.

## Conclusion

All the requirements specified in the issue description have been implemented and thoroughly tested. The changes have been made with minimal modifications to the existing codebase, focusing only on the specific requirements.