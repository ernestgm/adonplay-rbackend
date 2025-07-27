#!/bin/bash

# Test script for Media Management
# This script tests the new media management features including:
# - Media upload and management
# - Owner-based access control
# - Slide media ordering and duration
# - Audio assignment to image media
# - QR code assignment to media

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

# Create a business for the owner
print_header "Creating a business for the owner"
BUSINESS_RESPONSE=$(curl -s -X POST "$BASE_URL/businesses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d "{\"name\": \"Owner's Business\", \"description\": \"A business for testing media management\", \"owner_id\": $OWNER_ID}")

echo "Response: $BUSINESS_RESPONSE"

# Extract business ID
BUSINESS_ID=$(echo $BUSINESS_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Create a slide for the business
print_header "Creating a slide for the business"
SLIDE_RESPONSE=$(curl -s -X POST "$BASE_URL/slides" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d "{\"name\": \"Test Slide\", \"business_id\": $BUSINESS_ID}")

echo "Response: $SLIDE_RESPONSE"

# Extract slide ID
SLIDE_ID=$(echo $SLIDE_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Create a QR for the business
print_header "Creating a QR for the business"
QR_RESPONSE=$(curl -s -X POST "$BASE_URL/qrs" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d "{\"name\": \"Test QR\", \"info\": \"QR Info\", \"position\": \"center\", \"business_id\": $BUSINESS_ID}")

echo "Response: $QR_RESPONSE"

# Extract QR ID
QR_ID=$(echo $QR_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 1: Upload an image media
print_header "Test 1: Upload an image media"
# Create a temporary image file
echo "Creating a temporary image file..."
echo "This is a test image" > test_image.txt

IMAGE_RESPONSE=$(curl -s -X POST "$BASE_URL/media" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -F "media_type=image" \
  -F "file=@test_image.txt" \
  -F "owner_id=$OWNER_ID" \
  -F "business_id=$BUSINESS_ID")

echo "Response: $IMAGE_RESPONSE"

# Extract image media ID
IMAGE_MEDIA_ID=$(echo $IMAGE_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 2: Upload an audio media
print_header "Test 2: Upload an audio media"
# Create a temporary audio file
echo "Creating a temporary audio file..."
echo "This is a test audio" > test_audio.txt

AUDIO_RESPONSE=$(curl -s -X POST "$BASE_URL/media" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -F "media_type=audio" \
  -F "file=@test_audio.txt" \
  -F "owner_id=$OWNER_ID" \
  -F "business_id=$BUSINESS_ID")

echo "Response: $AUDIO_RESPONSE"

# Extract audio media ID
AUDIO_MEDIA_ID=$(echo $AUDIO_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 3: Upload a video media
print_header "Test 3: Upload a video media"
# Create a temporary video file
echo "Creating a temporary video file..."
echo "This is a test video" > test_video.txt

VIDEO_RESPONSE=$(curl -s -X POST "$BASE_URL/media" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -F "media_type=video" \
  -F "file=@test_video.txt" \
  -F "owner_id=$OWNER_ID" \
  -F "business_id=$BUSINESS_ID")

echo "Response: $VIDEO_RESPONSE"

# Extract video media ID
VIDEO_MEDIA_ID=$(echo $VIDEO_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 4: Add image media to slide with audio and QR
print_header "Test 4: Add image media to slide with audio and QR"
SLIDE_MEDIA_RESPONSE=$(curl -s -X POST "$BASE_URL/slide_media" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d "{\"slide_id\": $SLIDE_ID, \"media_id\": $IMAGE_MEDIA_ID, \"order\": 0, \"duration\": 10, \"audio_media_id\": $AUDIO_MEDIA_ID, \"qr_id\": $QR_ID, \"description\": \"Image with audio and QR\", \"text_size\": \"medium\", \"description_position\": \"bottom\"}")

echo "Response: $SLIDE_MEDIA_RESPONSE"

# Extract slide media ID
SLIDE_MEDIA_ID=$(echo $SLIDE_MEDIA_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 5: Add video media to slide
print_header "Test 5: Add video media to slide"
SLIDE_MEDIA_VIDEO_RESPONSE=$(curl -s -X POST "$BASE_URL/slide_media" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d "{\"slide_id\": $SLIDE_ID, \"media_id\": $VIDEO_MEDIA_ID, \"order\": 1, \"duration\": 15, \"description\": \"Video media\", \"text_size\": \"large\", \"description_position\": \"top\"}")

echo "Response: $SLIDE_MEDIA_VIDEO_RESPONSE"

# Extract slide media video ID
SLIDE_MEDIA_VIDEO_ID=$(echo $SLIDE_MEDIA_VIDEO_RESPONSE | grep -o '"id":[0-9]*' | sed 's/"id"://')

# Test 6: Get all media for a slide
print_header "Test 6: Get all media for a slide"
SLIDE_MEDIA_LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/slides/$SLIDE_ID/media" \
  -H "Authorization: Bearer $OWNER_TOKEN")

echo "Response: $SLIDE_MEDIA_LIST_RESPONSE"

# Test 7: Reorder media in a slide
print_header "Test 7: Reorder media in a slide"
REORDER_RESPONSE=$(curl -s -X POST "$BASE_URL/slides/$SLIDE_ID/media/reorder" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d "{\"order\": [$VIDEO_MEDIA_ID, $IMAGE_MEDIA_ID]}")

echo "Response: $REORDER_RESPONSE"

# Test 8: Update slide media
print_header "Test 8: Update slide media"
UPDATE_SLIDE_MEDIA_RESPONSE=$(curl -s -X PUT "$BASE_URL/slide_media/$SLIDE_MEDIA_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OWNER_TOKEN" \
  -d "{\"duration\": 20, \"description\": \"Updated description\", \"text_size\": \"small\", \"description_position\": \"center\"}")

echo "Response: $UPDATE_SLIDE_MEDIA_RESPONSE"

# Test 9: Owner-based access control - Another owner tries to access media
print_header "Test 9: Owner-based access control - Another owner tries to access media"
# Create another owner
OWNER2_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "Owner 2", "email": "owner2@example.com", "password": "password123", "password_confirmation": "password123", "role": "owner"}')

echo "Response: $OWNER2_RESPONSE"

# Login as owner 2
OWNER2_LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "owner2@example.com", "password": "password123"}')

echo "Response: $OWNER2_LOGIN_RESPONSE"

# Extract owner 2 token
OWNER2_TOKEN=$(echo $OWNER2_LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')

# Owner 2 tries to access slide media
ACCESS_DENIED_RESPONSE=$(curl -s -X GET "$BASE_URL/slides/$SLIDE_ID/media" \
  -H "Authorization: Bearer $OWNER2_TOKEN")

echo "Response: $ACCESS_DENIED_RESPONSE"

# Check if access was denied
if echo $ACCESS_DENIED_RESPONSE | grep -q "Unauthorized"; then
  echo "Success: Owner 2 was denied access to Owner 1's slide media"
else
  print_error "Owner 2 was able to access Owner 1's slide media"
fi

# Test 10: Admin can access any media
print_header "Test 10: Admin can access any media"
ADMIN_ACCESS_RESPONSE=$(curl -s -X GET "$BASE_URL/slides/$SLIDE_ID/media" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

echo "Response: $ADMIN_ACCESS_RESPONSE"

# Check if admin could access the media
if echo $ADMIN_ACCESS_RESPONSE | grep -q "Unauthorized"; then
  print_error "Admin was denied access to slide media"
else
  echo "Success: Admin can access any slide media"
fi

# Test 11: Delete slide media
print_header "Test 11: Delete slide media"
DELETE_SLIDE_MEDIA_RESPONSE=$(curl -s -X DELETE "$BASE_URL/slide_media/$SLIDE_MEDIA_ID" \
  -H "Authorization: Bearer $OWNER_TOKEN")

echo "Response: $DELETE_SLIDE_MEDIA_RESPONSE"

# Clean up temporary files
rm -f test_image.txt test_audio.txt test_video.txt

print_header "All tests completed"