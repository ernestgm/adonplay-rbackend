#!/bin/bash

# Test script for local storage implementation
echo "Testing local storage implementation..."

# Test 1: Create a media record with a file
echo "Test 1: Creating a media record with a file..."
curl -X POST \
  -H "Content-Type: multipart/form-data" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "media_type=image" \
  -F "file=@test_image.jpg" \
  http://localhost:3000/api/v1/media

# Test 2: Verify the file exists in the local storage directory
echo "Test 2: Verifying the file exists in the local storage directory..."
echo "Check the directory: public/uploads/desa/medias/user_YOUR_USER_ID/images/"

# Test 3: Update the media record with a new file
echo "Test 3: Updating the media record with a new file..."
curl -X PUT \
  -H "Content-Type: multipart/form-data" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "file=@test_image2.jpg" \
  http://localhost:3000/api/v1/media/YOUR_MEDIA_ID

# Test 4: Delete the media record
echo "Test 4: Deleting the media record..."
curl -X DELETE \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:3000/api/v1/media/YOUR_MEDIA_ID

echo "Tests completed. Please check the results manually."