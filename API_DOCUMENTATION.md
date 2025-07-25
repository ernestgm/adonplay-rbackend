# API Documentation

This document provides instructions on how to use the API endpoints for user management and authentication.

## Authentication

### Login

```
POST /api/v1/login
```

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com",
    "role": "admin",
    "phone": "1234567890",
    "enabled": true,
    "created_at": "2025-07-24T04:37:00.000Z",
    "updated_at": "2025-07-24T04:37:00.000Z"
  }
}
```

### Logout

```
DELETE /api/v1/logout
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response:**

```json
{
  "message": "Logged out successfully"
}
```

## Users

### Create User (Signup)

```
POST /api/v1/users
```

**Request Body:**

```json
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "owner",
  "phone": "1234567890",
  "enabled": true
}
```

**Response:**

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "user@example.com",
  "role": "owner",
  "phone": "1234567890",
  "enabled": true,
  "created_at": "2025-07-24T04:37:00.000Z",
  "updated_at": "2025-07-24T04:37:00.000Z"
}
```

### Get All Users (Admin Only)

```
GET /api/v1/users
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response:**

```json
[
  {
    "id": 2,
    "name": "Jane Smith",
    "email": "jane@example.com",
    "role": "owner",
    "created_at": "2025-07-24T04:37:00.000Z",
    "updated_at": "2025-07-24T04:37:00.000Z"
  }
]
```

**Note:** The response will not include the currently authenticated user.

### Get User

```
GET /api/v1/users/:id
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response:**

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "user@example.com",
  "role": "admin",
  "created_at": "2025-07-24T04:37:00.000Z",
  "updated_at": "2025-07-24T04:37:00.000Z"
}
```

### Update User (Owner or Admin Only)

```
PUT /api/v1/users/:id
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Request Body:**

```json
{
  "name": "John Updated",
  "email": "updated@example.com",
  "password": "newpassword",
  "password_confirmation": "newpassword",
  "phone": "9876543210",
  "enabled": true
}
```

**Response:**

```json
{
  "id": 1,
  "name": "John Updated",
  "email": "updated@example.com",
  "role": "admin",
  "phone": "9876543210",
  "enabled": true,
  "created_at": "2025-07-24T04:37:00.000Z",
  "updated_at": "2025-07-24T04:38:00.000Z"
}
```

**Note:** Users with the "owner" role can only edit their own profile. Admins can edit any user profile.

### Delete User (Owner or Admin Only)

```
DELETE /api/v1/users/:id
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response:**

```
204 No Content
```

**Error Response (When trying to delete your own account):**

```json
{
  "error": "You cannot delete your own account"
}
```

**Note:** Users cannot delete their own account. This restriction applies to both admin and owner roles.

### Delete Multiple Users (Admin Only)

```
DELETE /api/v1/users
```

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Request Body:**

```json
{
  "ids": [2, 3, 4]
}
```

**Response:**

```json
{
  "message": "3 users deleted successfully"
}
```

**Error Response (When no IDs are provided):**

```json
{
  "error": "No user IDs provided"
}
```

**Note:** 
- This endpoint allows deleting multiple users at once by providing an array of user IDs.
- The current user's ID will be automatically excluded from the deletion, even if it's included in the request.
- Only admin users can access this endpoint.

## Testing with curl

Here are some example curl commands to test the API:

### Signup

```bash
curl -X POST http://localhost:9000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "user@example.com", "password": "password123", "password_confirmation": "password123", "role": "admin", "phone": "1234567890", "enabled": true}'
```

### Login

```bash
curl -X POST http://localhost:9000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

### Get All Users (Admin Only)

```bash
curl -X GET http://localhost:9000/api/v1/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Get User

```bash
curl -X GET http://localhost:9000/api/v1/users/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Update User (Owner or Admin Only)

```bash
curl -X PUT http://localhost:9000/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"name": "John Updated", "email": "updated@example.com", "phone": "9876543210", "enabled": true}'
```

### Delete User (Owner or Admin Only)

```bash
curl -X DELETE http://localhost:9000/api/v1/users/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Delete Multiple Users (Admin Only)

```bash
curl -X DELETE http://localhost:9000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"ids": [2, 3, 4]}'
```

## Error Handling

When a validation error occurs, the API returns a structured error response with the field name and the error message. The response has the following format:

```json
{
  "errors": {
    "field_name": [
      {
        "type": "error_type",
        "message": "Error message for the field"
      }
    ]
  }
}
```

For example, if you try to create a user without providing a name, you'll get the following response:

```json
{
  "errors": {
    "name": [
      {
        "type": "blank",
        "message": "El nombre es obligatorio."
      }
    ]
  }
}
```

If multiple fields have errors, they will all be included in the response:

```json
{
  "errors": {
    "name": [
      {
        "type": "blank",
        "message": "El nombre es obligatorio."
      }
    ],
    "email": [
      {
        "type": "invalid",
        "message": "El formato del correo electrónico no es válido."
      }
    ]
  }
}
```

## Notes

- The token received from the login endpoint should be included in the Authorization header for all protected endpoints.
- All API endpoints now accept direct JSON format without nesting. For example, instead of `{"user": {"name": "..."}}`, use `{"name": "..."}`.
- Only admin users can access the index endpoint to list all users.
- The index endpoint excludes the currently authenticated user from the results.
- Users with the "owner" role can only edit their own profile, while admins can edit any profile.
- Users cannot delete their own account, regardless of their role.
- The bulk delete endpoint allows admins to delete multiple users at once and automatically excludes the current user from deletion.
- When updating a user, you can omit the password and password_confirmation fields if you don't want to change the password.