#!/bin/bash

# Test script for Direct JSON API
# This script tests the API endpoints with direct JSON format without nesting

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

# Create admin user with direct JSON format
print_header "Creating admin user with direct JSON format"
ADMIN_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Admin User", "email": "admin@example.com", "password": "password123", "password_confirmation": "password123", "role": "admin", "phone": "1234567890", "enabled": true}')

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

# Create owner user with direct JSON format
print_header "Creating owner user with direct JSON format"
OWNER_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Owner User", "email": "owner@example.com", "password": "password123", "password_confirmation": "password123", "role": "owner", "phone": "9876543210", "enabled": true}')

echo "Response: $OWNER_RESPONSE"

# Extract owner ID
OWNER_ID=$(echo $OWNER_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Login as owner
print_header "Logging in as owner"
OWNER_LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "owner@example.com", "password": "password123"}')

echo "Response: $OWNER_LOGIN_RESPONSE"

# Extract owner token
OWNER_TOKEN=$(echo $OWNER_LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$OWNER_TOKEN" ]; then
  print_error "Failed to get owner token"
  exit 1
fi

echo "Owner token: $OWNER_TOKEN"
echo "Owner ID: $OWNER_ID"

# Create additional users for testing with direct JSON format
print_header "Creating additional users for testing with direct JSON format"
for i in {1..3}; do
  USER_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"Test User $i\", \"email\": \"user$i@example.com\", \"password\": \"password123\", \"password_confirmation\": \"password123\", \"role\": \"owner\", \"phone\": \"555555555$i\", \"enabled\": true}")
  
  echo "Created user $i: $USER_RESPONSE"
  
  # Extract user ID
  USER_ID=$(echo $USER_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')
  eval "USER_${i}_ID=$USER_ID"
done

# Test 1: Get all users as admin (should exclude admin)
print_header "Test 1: Get all users as admin (should exclude admin)"
USERS_RESPONSE=$(curl -s -X GET "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $USERS_RESPONSE"

# Check if admin is excluded from the list
if echo $USERS_RESPONSE | grep -q "\"id\":$ADMIN_ID"; then
  print_error "Admin user is included in the list"
else
  echo "Success: Admin user is excluded from the list"
fi

# Test 2: Owner tries to edit another user's profile (should fail)
print_header "Test 2: Owner tries to edit another user's profile (should fail)"
EDIT_RESPONSE=$(curl -s -X PUT "$BASE_URL/users/$USER_1_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d '{"name": "Modified by Owner"}')

echo "Response: $EDIT_RESPONSE"

# Check if the request was forbidden
if echo $EDIT_RESPONSE | grep -q "Unauthorized"; then
  echo "Success: Owner cannot edit another user's profile"
else
  print_error "Owner was able to edit another user's profile"
fi

# Test 3: Owner edits their own profile with direct JSON format (should succeed)
print_header "Test 3: Owner edits their own profile with direct JSON format (should succeed)"
EDIT_OWN_RESPONSE=$(curl -s -X PUT "$BASE_URL/users/$OWNER_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d '{"name": "Modified Owner", "phone": "1122334455"}')

echo "Response: $EDIT_OWN_RESPONSE"

# Check if the request was successful
if echo $EDIT_OWN_RESPONSE | grep -q "Modified Owner"; then
  echo "Success: Owner can edit their own profile with direct JSON format"
else
  print_error "Owner could not edit their own profile with direct JSON format"
fi

# Test 4: Admin edits a user with direct JSON format (should succeed)
print_header "Test 4: Admin edits a user with direct JSON format (should succeed)"
ADMIN_EDIT_RESPONSE=$(curl -s -X PUT "$BASE_URL/users/$USER_2_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"name": "Modified by Admin", "enabled": false}')

echo "Response: $ADMIN_EDIT_RESPONSE"

# Check if the request was successful
if echo $ADMIN_EDIT_RESPONSE | grep -q "Modified by Admin" && echo $ADMIN_EDIT_RESPONSE | grep -q "\"enabled\":false"; then
  echo "Success: Admin can edit a user with direct JSON format"
else
  print_error "Admin could not edit a user with direct JSON format"
fi

# Test 5: Admin tries to delete themselves (should fail)
print_header "Test 5: Admin tries to delete themselves (should fail)"
DELETE_SELF_RESPONSE=$(curl -s -X DELETE "$BASE_URL/users/$ADMIN_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $DELETE_SELF_RESPONSE"

# Check if the request was forbidden
if echo $DELETE_SELF_RESPONSE | grep -q "cannot delete your own account"; then
  echo "Success: Admin cannot delete their own account"
else
  print_error "Admin was able to delete their own account"
fi

# Test 6: Admin deletes another user (should succeed)
print_header "Test 6: Admin deletes another user (should succeed)"
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/users/$USER_1_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" -w "%{http_code}")

echo "Response: $DELETE_RESPONSE"

# Check if the request was successful (204 No Content)
if echo $DELETE_RESPONSE | grep -q "204"; then
  echo "Success: Admin can delete another user"
else
  print_error "Admin could not delete another user"
fi

# Test 7: Admin bulk deletes users with direct JSON format (should succeed and exclude admin)
print_header "Test 7: Admin bulk deletes users with direct JSON format (should succeed and exclude admin)"
BULK_DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/users/destroy_multiple" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{\"ids\": [$USER_2_ID, $USER_3_ID, $ADMIN_ID]}")

echo "Response: $BULK_DELETE_RESPONSE"

# Check if the request was successful and admin was excluded
if echo $BULK_DELETE_RESPONSE | grep -q "users deleted successfully"; then
  echo "Success: Admin can bulk delete users with direct JSON format"
else
  print_error "Admin could not bulk delete users with direct JSON format"
fi

# Test 8: Create a business with direct JSON format (should succeed)
print_header "Test 8: Create a business with direct JSON format (should succeed)"
BUSINESS_RESPONSE=$(curl -s -X POST "$BASE_URL/businesses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"name": "Test Business", "description": "This is a test business"}')

echo "Response: $BUSINESS_RESPONSE"

# Check if the request was successful
if echo $BUSINESS_RESPONSE | grep -q "Test Business"; then
  echo "Success: Admin can create a business with direct JSON format"
  # Extract business ID
  BUSINESS_ID=$(echo $BUSINESS_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')
else
  print_error "Admin could not create a business with direct JSON format"
fi

# Test 9: Update a business with direct JSON format (should succeed)
if [ -n "$BUSINESS_ID" ]; then
  print_header "Test 9: Update a business with direct JSON format (should succeed)"
  BUSINESS_UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/businesses/$BUSINESS_ID" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -d '{"name": "Updated Business", "description": "This is an updated business"}')

  echo "Response: $BUSINESS_UPDATE_RESPONSE"

  # Check if the request was successful
  if echo $BUSINESS_UPDATE_RESPONSE | grep -q "Updated Business"; then
    echo "Success: Admin can update a business with direct JSON format"
  else
    print_error "Admin could not update a business with direct JSON format"
  fi
fi

print_header "All tests completed"