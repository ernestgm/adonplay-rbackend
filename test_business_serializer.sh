#!/bin/bash

# Test script for BusinessSerializer
# This script tests that the BusinessSerializer includes owner_id and owner details in the response

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

# Create owner user
print_header "Creating owner user"
OWNER_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Owner User", "email": "owner@example.com", "password": "password123", "password_confirmation": "password123", "role": "owner"}')

echo "Response: $OWNER_RESPONSE"

# Extract owner ID
OWNER_ID=$(echo $OWNER_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Create business with owner
print_header "Creating business with owner"
BUSINESS_RESPONSE=$(curl -s -X POST "$BASE_URL/businesses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{\"name\": \"Test Business\", \"description\": \"Test Description\", \"owner_id\": $OWNER_ID}")

echo "Response: $BUSINESS_RESPONSE"

# Check if the response contains owner_id and owner details
if echo $BUSINESS_RESPONSE | grep -q "\"owner_id\":$OWNER_ID"; then
  echo "Success: Response contains owner_id"
else
  print_error "Response does not contain owner_id"
fi

if echo $BUSINESS_RESPONSE | grep -q "\"owner\":{"; then
  echo "Success: Response contains owner details"
else
  print_error "Response does not contain owner details"
fi

if echo $BUSINESS_RESPONSE | grep -q "\"name\":\"Owner User\""; then
  echo "Success: Response contains owner name"
else
  print_error "Response does not contain owner name"
fi

# Get business by ID
print_header "Getting business by ID"
BUSINESS_ID=$(echo $BUSINESS_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')
GET_BUSINESS_RESPONSE=$(curl -s -X GET "$BASE_URL/businesses/$BUSINESS_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $GET_BUSINESS_RESPONSE"

# Check if the response contains owner_id and owner details
if echo $GET_BUSINESS_RESPONSE | grep -q "\"owner_id\":$OWNER_ID"; then
  echo "Success: Response contains owner_id"
else
  print_error "Response does not contain owner_id"
fi

if echo $GET_BUSINESS_RESPONSE | grep -q "\"owner\":{"; then
  echo "Success: Response contains owner details"
else
  print_error "Response does not contain owner details"
fi

if echo $GET_BUSINESS_RESPONSE | grep -q "\"name\":\"Owner User\""; then
  echo "Success: Response contains owner name"
else
  print_error "Response does not contain owner name"
fi

# Get all businesses
print_header "Getting all businesses"
GET_ALL_BUSINESSES_RESPONSE=$(curl -s -X GET "$BASE_URL/businesses" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $GET_ALL_BUSINESSES_RESPONSE"

# Check if the response contains owner_id and owner details
if echo $GET_ALL_BUSINESSES_RESPONSE | grep -q "\"owner_id\":$OWNER_ID"; then
  echo "Success: Response contains owner_id"
else
  print_error "Response does not contain owner_id"
fi

if echo $GET_ALL_BUSINESSES_RESPONSE | grep -q "\"owner\":{"; then
  echo "Success: Response contains owner details"
else
  print_error "Response does not contain owner details"
fi

if echo $GET_ALL_BUSINESSES_RESPONSE | grep -q "\"name\":\"Owner User\""; then
  echo "Success: Response contains owner name"
else
  print_error "Response does not contain owner name"
fi

print_header "All tests completed"