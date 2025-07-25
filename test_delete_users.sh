#!/bin/bash

# Test script for DELETE /api/v1/users endpoint
# This script tests the bulk deletion of users

# Set the base URL
BASE_URL="http://localhost:9000/api/v1"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
  echo -e "\n${GREEN}=== $1 ===${NC}\n"
}

# Function to print error messages
print_error() {
  echo -e "${RED}ERROR: $1${NC}"
}

# Create admin user
print_header "Creating admin user"
ADMIN_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Admin User", "email": "admin@example.com", "password": "password123", "password_confirmation": "password123", "role": "admin"}')

echo "Response: $ADMIN_RESPONSE"

# Login as admin
print_header "Logging in as admin"
ADMIN_LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}')

echo "Response: $ADMIN_LOGIN_RESPONSE"

# Extract admin token
ADMIN_TOKEN=$(echo $ADMIN_LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')
ADMIN_ID=$(echo $ADMIN_LOGIN_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

if [ -z "$ADMIN_TOKEN" ]; then
  print_error "Failed to get admin token"
  exit 1
fi

echo "Admin token: $ADMIN_TOKEN"
echo "Admin ID: $ADMIN_ID"

# Create test users
print_header "Creating test users"
for i in {1..3}; do
  USER_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"Test User $i\", \"email\": \"user$i@example.com\", \"password\": \"password123\", \"password_confirmation\": \"password123\", \"role\": \"owner\"}")
  
  echo "Created user $i: $USER_RESPONSE"
  
  # Extract user ID
  USER_ID=$(echo $USER_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')
  eval "USER_${i}_ID=$USER_ID"
done

# Test 1: Delete a single user with DELETE /api/v1/users
print_header "Test 1: Delete a single user with DELETE /api/v1/users"
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{\"ids\": [$USER_1_ID]}")

echo "Response: $DELETE_RESPONSE"

# Check if the request was successful
if echo $DELETE_RESPONSE | grep -q "users deleted successfully"; then
  echo "Success: User deleted successfully"
else
  print_error "Failed to delete user"
fi

# Test 2: Delete multiple users with DELETE /api/v1/users
print_header "Test 2: Delete multiple users with DELETE /api/v1/users"
DELETE_MULTIPLE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{\"ids\": [$USER_2_ID, $USER_3_ID]}")

echo "Response: $DELETE_MULTIPLE_RESPONSE"

# Check if the request was successful
if echo $DELETE_MULTIPLE_RESPONSE | grep -q "users deleted successfully"; then
  echo "Success: Multiple users deleted successfully"
else
  print_error "Failed to delete multiple users"
fi

# Test 3: Try to delete admin user (should fail)
print_header "Test 3: Try to delete admin user (should fail)"
DELETE_ADMIN_RESPONSE=$(curl -s -X DELETE "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{\"ids\": [$ADMIN_ID]}")

echo "Response: $DELETE_ADMIN_RESPONSE"

# Check if the request was forbidden
if echo $DELETE_ADMIN_RESPONSE | grep -q "cannot delete your own account"; then
  echo "Success: Admin cannot delete their own account"
else
  print_error "Admin was able to delete their own account or unexpected error occurred"
fi

# Test 4: Try to delete with empty IDs array (should fail)
print_header "Test 4: Try to delete with empty IDs array (should fail)"
DELETE_EMPTY_RESPONSE=$(curl -s -X DELETE "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"ids": []}')

echo "Response: $DELETE_EMPTY_RESPONSE"

# Check if the request was bad request
if echo $DELETE_EMPTY_RESPONSE | grep -q "No user IDs provided"; then
  echo "Success: Empty IDs array rejected"
else
  print_error "Empty IDs array was accepted or unexpected error occurred"
fi

print_header "All tests completed"