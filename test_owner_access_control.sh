#!/bin/bash

# Test script for owner-based access control and bulk deletion
# This script tests that users with the "owner" role can only access and modify their own entities,
# and that the bulk deletion functionality works correctly.

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

# Create owner users
print_header "Creating owner users"
OWNER1_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Owner 1", "email": "owner1@example.com", "password": "password123", "password_confirmation": "password123", "role": "owner"}')

echo "Response: $OWNER1_RESPONSE"

OWNER2_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Owner 2", "email": "owner2@example.com", "password": "password123", "password_confirmation": "password123", "role": "owner"}')

echo "Response: $OWNER2_RESPONSE"

# Extract owner IDs
OWNER1_ID=$(echo $OWNER1_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')
OWNER2_ID=$(echo $OWNER2_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Login as owner 1
print_header "Logging in as owner 1"
OWNER1_LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "owner1@example.com", "password": "password123"}')

echo "Response: $OWNER1_LOGIN_RESPONSE"

# Extract owner 1 token
OWNER1_TOKEN=$(echo $OWNER1_LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$OWNER1_TOKEN" ]; then
  print_error "Failed to get owner 1 token"
  exit 1
fi

echo "Owner 1 token: $OWNER1_TOKEN"

# Login as owner 2
print_header "Logging in as owner 2"
OWNER2_LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "owner2@example.com", "password": "password123"}')

echo "Response: $OWNER2_LOGIN_RESPONSE"

# Extract owner 2 token
OWNER2_TOKEN=$(echo $OWNER2_LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$OWNER2_TOKEN" ]; then
  print_error "Failed to get owner 2 token"
  exit 1
fi

echo "Owner 2 token: $OWNER2_TOKEN"

# Create businesses for each owner
print_header "Creating business for owner 1"
BUSINESS1_RESPONSE=$(curl -s -X POST "$BASE_URL/businesses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER1_TOKEN" \
  -d '{"name": "Business 1", "description": "Business 1 description"}')

echo "Response: $BUSINESS1_RESPONSE"

# Extract business 1 ID
BUSINESS1_ID=$(echo $BUSINESS1_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

print_header "Creating business for owner 2"
BUSINESS2_RESPONSE=$(curl -s -X POST "$BASE_URL/businesses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER2_TOKEN" \
  -d '{"name": "Business 2", "description": "Business 2 description"}')

echo "Response: $BUSINESS2_RESPONSE"

# Extract business 2 ID
BUSINESS2_ID=$(echo $BUSINESS2_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 1: Owner 1 tries to access business 2 (should fail)
print_header "Test 1: Owner 1 tries to access business 2 (should fail)"
ACCESS_RESPONSE=$(curl -s -X GET "$BASE_URL/businesses/$BUSINESS2_ID" \
  -H "Authorization: Bearer $OWNER1_TOKEN")

echo "Response: $ACCESS_RESPONSE"

# Check if the request was forbidden
if echo $ACCESS_RESPONSE | grep -q "Unauthorized"; then
  echo "Success: Owner 1 cannot access business 2"
else
  print_error "Owner 1 was able to access business 2"
fi

# Test 2: Owner 1 tries to update business 2 (should fail)
print_header "Test 2: Owner 1 tries to update business 2 (should fail)"
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/businesses/$BUSINESS2_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER1_TOKEN" \
  -d '{"name": "Modified by Owner 1"}')

echo "Response: $UPDATE_RESPONSE"

# Check if the request was forbidden
if echo $UPDATE_RESPONSE | grep -q "Unauthorized"; then
  echo "Success: Owner 1 cannot update business 2"
else
  print_error "Owner 1 was able to update business 2"
fi

# Test 3: Owner 1 tries to delete business 2 (should fail)
print_header "Test 3: Owner 1 tries to delete business 2 (should fail)"
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/businesses/$BUSINESS2_ID" \
  -H "Authorization: Bearer $OWNER1_TOKEN")

echo "Response: $DELETE_RESPONSE"

# Check if the request was forbidden
if echo $DELETE_RESPONSE | grep -q "Unauthorized"; then
  echo "Success: Owner 1 cannot delete business 2"
else
  print_error "Owner 1 was able to delete business 2"
fi

# Create slides for each business
print_header "Creating slide for business 1"
SLIDE1_RESPONSE=$(curl -s -X POST "$BASE_URL/slides" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER1_TOKEN" \
  -d "{\"name\": \"Slide 1\", \"business_id\": $BUSINESS1_ID}")

echo "Response: $SLIDE1_RESPONSE"

# Extract slide 1 ID
SLIDE1_ID=$(echo $SLIDE1_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

print_header "Creating slide for business 2"
SLIDE2_RESPONSE=$(curl -s -X POST "$BASE_URL/slides" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER2_TOKEN" \
  -d "{\"name\": \"Slide 2\", \"business_id\": $BUSINESS2_ID}")

echo "Response: $SLIDE2_RESPONSE"

# Extract slide 2 ID
SLIDE2_ID=$(echo $SLIDE2_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 4: Owner 1 tries to access slide 2 (should fail)
print_header "Test 4: Owner 1 tries to access slide 2 (should fail)"
ACCESS_SLIDE_RESPONSE=$(curl -s -X GET "$BASE_URL/slides/$SLIDE2_ID" \
  -H "Authorization: Bearer $OWNER1_TOKEN")

echo "Response: $ACCESS_SLIDE_RESPONSE"

# Check if the request was forbidden
if echo $ACCESS_SLIDE_RESPONSE | grep -q "Unauthorized"; then
  echo "Success: Owner 1 cannot access slide 2"
else
  print_error "Owner 1 was able to access slide 2"
fi

# Create multiple slides for bulk deletion test
print_header "Creating multiple slides for bulk deletion test"
for i in {1..3}; do
  SLIDE_RESPONSE=$(curl -s -X POST "$BASE_URL/slides" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OWNER1_TOKEN" \
    -d "{\"name\": \"Bulk Test Slide $i\", \"business_id\": $BUSINESS1_ID}")
  
  echo "Created slide $i: $SLIDE_RESPONSE"
  
  # Extract slide ID
  SLIDE_ID=$(echo $SLIDE_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')
  eval "BULK_SLIDE_${i}_ID=$SLIDE_ID"
done

# Test 5: Bulk delete slides
print_header "Test 5: Bulk delete slides"
BULK_DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/slides" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER1_TOKEN" \
  -d "{\"ids\": [$BULK_SLIDE_1_ID, $BULK_SLIDE_2_ID, $BULK_SLIDE_3_ID]}")

echo "Response: $BULK_DELETE_RESPONSE"

# Check if the request was successful
if echo $BULK_DELETE_RESPONSE | grep -q "slides deleted successfully"; then
  echo "Success: Owner 1 can bulk delete their own slides"
else
  print_error "Owner 1 could not bulk delete their own slides"
fi

# Test 6: Owner 1 tries to bulk delete slides including one from owner 2 (should partially succeed)
print_header "Test 6: Owner 1 tries to bulk delete slides including one from owner 2 (should partially succeed)"
MIXED_DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/slides" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER1_TOKEN" \
  -d "{\"ids\": [$SLIDE1_ID, $SLIDE2_ID]}")

echo "Response: $MIXED_DELETE_RESPONSE"

# Check if the request was partially successful (only deleted owner 1's slide)
if echo $MIXED_DELETE_RESPONSE | grep -q "1 slides deleted successfully"; then
  echo "Success: Owner 1 can only delete their own slides in bulk deletion"
else
  print_error "Unexpected result in mixed bulk deletion"
fi

# Test 7: Admin can access and modify any business
print_header "Test 7: Admin can access and modify any business"
ADMIN_ACCESS_RESPONSE=$(curl -s -X GET "$BASE_URL/businesses/$BUSINESS2_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $ADMIN_ACCESS_RESPONSE"

# Check if the request was successful
if echo $ADMIN_ACCESS_RESPONSE | grep -q "\"id\":$BUSINESS2_ID"; then
  echo "Success: Admin can access any business"
else
  print_error "Admin could not access business 2"
fi

# Test 8: Admin can bulk delete entities from any owner
print_header "Test 8: Admin can bulk delete entities from any owner"
# Create some test entities for admin to delete
MARQUEE1_RESPONSE=$(curl -s -X POST "$BASE_URL/marquees" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER1_TOKEN" \
  -d "{\"name\": \"Marquee 1\", \"message\": \"Test message\", \"background_color\": \"#000000\", \"text_color\": \"#FFFFFF\", \"business_id\": $BUSINESS1_ID}")

echo "Created marquee: $MARQUEE1_RESPONSE"
MARQUEE1_ID=$(echo $MARQUEE1_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

MARQUEE2_RESPONSE=$(curl -s -X POST "$BASE_URL/marquees" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER2_TOKEN" \
  -d "{\"name\": \"Marquee 2\", \"message\": \"Test message\", \"background_color\": \"#000000\", \"text_color\": \"#FFFFFF\", \"business_id\": $BUSINESS2_ID}")

echo "Created marquee: $MARQUEE2_RESPONSE"
MARQUEE2_ID=$(echo $MARQUEE2_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Admin bulk deletes marquees from both owners
ADMIN_BULK_DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/marquees" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{\"ids\": [$MARQUEE1_ID, $MARQUEE2_ID]}")

echo "Response: $ADMIN_BULK_DELETE_RESPONSE"

# Check if the request was successful
if echo $ADMIN_BULK_DELETE_RESPONSE | grep -q "2 marquees deleted successfully"; then
  echo "Success: Admin can bulk delete entities from any owner"
else
  print_error "Admin could not bulk delete entities from different owners"
fi

print_header "All tests completed"