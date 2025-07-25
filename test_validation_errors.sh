#!/bin/bash

# Test script for validation error messages
# This script tests that the API returns structured error responses with field names and error messages

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

# Test 1: Create user with missing required fields
print_header "Test 1: Create user with missing required fields"
USER_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}')

echo "Response: $USER_RESPONSE"

# Check if the response contains structured error messages
if echo $USER_RESPONSE | grep -q '"errors":{"name"'; then
  echo "Success: Response contains structured error for name field"
else
  print_error "Response does not contain structured error for name field"
fi

if echo $USER_RESPONSE | grep -q '"message":"El nombre es obligatorio"'; then
  echo "Success: Response contains custom error message for name field"
else
  print_error "Response does not contain custom error message for name field"
fi

# Test 2: Create business with missing required fields
print_header "Test 2: Create business with missing required fields"

# First, login to get a token
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

if [ -z "$TOKEN" ]; then
  print_error "Failed to get token. Make sure you have an admin user with the credentials above."
  exit 1
fi

BUSINESS_RESPONSE=$(curl -s -X POST "$BASE_URL/businesses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name": "Test Business"}')

echo "Response: $BUSINESS_RESPONSE"

# Check if the response contains structured error messages
if echo $BUSINESS_RESPONSE | grep -q '"errors":{"description"'; then
  echo "Success: Response contains structured error for description field"
else
  print_error "Response does not contain structured error for description field"
fi

if echo $BUSINESS_RESPONSE | grep -q '"message":"La descripción es obligatoria"'; then
  echo "Success: Response contains custom error message for description field"
else
  print_error "Response does not contain custom error message for description field"
fi

# Test 3: Create media with invalid media_type
print_header "Test 3: Create media with invalid media_type"
MEDIA_RESPONSE=$(curl -s -X POST "$BASE_URL/media" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"media_type": "invalid", "file_path": "/path/to/file"}')

echo "Response: $MEDIA_RESPONSE"

# Check if the response contains structured error messages
if echo $MEDIA_RESPONSE | grep -q '"errors":{"media_type"'; then
  echo "Success: Response contains structured error for media_type field"
else
  print_error "Response does not contain structured error for media_type field"
fi

if echo $MEDIA_RESPONSE | grep -q '"message":"El tipo de medio debe ser imagen, video o audio"'; then
  echo "Success: Response contains custom error message for media_type field"
else
  print_error "Response does not contain custom error message for media_type field"
fi

# Test 4: Update user with invalid email format
print_header "Test 4: Update user with invalid email format"
USER_ID=$(echo $LOGIN_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

if [ -z "$USER_ID" ]; then
  print_error "Failed to get user ID"
  exit 1
fi

UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/users/$USER_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"email": "invalid-email"}')

echo "Response: $UPDATE_RESPONSE"

# Check if the response contains structured error messages
if echo $UPDATE_RESPONSE | grep -q '"errors":{"email"'; then
  echo "Success: Response contains structured error for email field"
else
  print_error "Response does not contain structured error for email field"
fi

if echo $UPDATE_RESPONSE | grep -q '"message":"El formato del correo electrónico no es válido"'; then
  echo "Success: Response contains custom error message for email field"
else
  print_error "Response does not contain custom error message for email field"
fi

print_header "All tests completed"