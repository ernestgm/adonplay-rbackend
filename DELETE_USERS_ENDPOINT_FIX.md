# DELETE Users Endpoint Fix

## Issue Description

The DELETE /api/v1/users endpoint was returning a 404 Not Found error when a JSON payload with user IDs was sent to it:

```json
{"ids": [2]}
```

## Root Cause

The issue was caused by a mismatch between the route configuration and the client's expectation:

1. The client was sending DELETE requests to `/api/v1/users`
2. The server was configured to handle bulk user deletion at `/api/v1/users/destroy`
3. The API documentation and test script referred to the endpoint as `/api/v1/users/destroy_multiple`

This inconsistency resulted in 404 errors when the client tried to access the endpoint.

## Changes Made

### 1. Updated Route Configuration

Changed the route configuration in `config/routes.rb` from:

```ruby
resources :users, only: [:index, :show, :create, :update] do # Excluye :destroy por ahora
  collection do
    delete :destroy # Define una acción DELETE para la colección
  end
end
```

To:

```ruby
resources :users, only: [:index, :show, :create, :update]
delete '/users', to: 'users#destroy' # Define DELETE /api/v1/users para eliminar usuarios
```

This change maps the destroy action directly to DELETE /api/v1/users, which is what the client expects.

### 2. Updated API Documentation

Updated the API documentation to reflect the new endpoint URL:

- Changed the endpoint URL in the "Delete Multiple Users (Admin Only)" section from `DELETE /api/v1/users/destroy_multiple` to `DELETE /api/v1/users`
- Updated the curl example in the "Testing with curl" section to use the new endpoint URL

### 3. Created Test Script

Created a test script `test_delete_users.sh` to verify that the updated route works correctly. The script tests:

1. Deleting a single user with DELETE /api/v1/users
2. Deleting multiple users with DELETE /api/v1/users
3. Trying to delete the admin user (which should fail)
4. Trying to delete with an empty IDs array (which should fail)

## How to Test

Run the test script to verify that the updated route works correctly:

```bash
bash test_delete_users.sh
```

## Benefits

1. **Improved Client Compatibility**: The API now accepts DELETE requests at the endpoint the client expects (/api/v1/users)
2. **Consistency**: The route configuration, controller implementation, and API documentation are now consistent
3. **Better User Experience**: Clients no longer receive 404 errors when trying to delete users

## Note

The controller implementation did not need to be changed, as it was already designed to handle bulk deletion of users. Only the route configuration and documentation needed to be updated to match the client's expectation.