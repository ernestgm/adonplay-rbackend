# Media Management Features

## Overview

This document describes the new media management features implemented in the API. These features allow users to upload and manage different types of media (images, videos, audio), associate them with slides, and configure how they are displayed.

## Key Features

1. **Media Types Support**: The system now supports three types of media:
   - Images
   - Videos
   - Audio

2. **Owner-Based Access Control**: 
   - Administrators can manage all media
   - Owners can only create, edit, or delete their own media
   - Media is associated with both an owner (user) and a business

3. **Slide Media Management**:
   - Slides can have multiple media items
   - Media can be ordered within a slide
   - Each media has a configurable duration (default: 5 seconds)
   - Image media can have an associated audio
   - Media can have an associated QR code
   - Media can have a description with configurable position and text size

## Database Changes

The following changes were made to the database schema:

1. **Media Table**:
   - Added `owner_id` (references users)
   - Added `business_id` (references businesses)
   - Added index on `media_type` for faster queries

2. **Slide Media Table**:
   - Added `order` field for ordering media within a slide
   - Added `duration` field for specifying how long to display the media
   - Added `audio_media_id` field for associating audio with image media
   - Added `qr_id` field for associating a QR code with the media
   - Added `description` field for adding a description to the media
   - Added `text_size` field for configuring the size of the description text
   - Added `description_position` field for configuring the position of the description
   - Added index on `[slide_id, order]` for faster sorting

## API Endpoints

### Media Endpoints

```
GET /api/v1/media
```
Returns a list of all media for the current user (or all media for admins).

Query parameters:
- `media_type`: Filter by media type (image, video, audio)

```
GET /api/v1/media/:id
```
Returns details for a specific media.

```
POST /api/v1/media
```
Creates a new media. Supports multipart/form-data for file uploads.

Parameters:
- `media_type`: Type of media (image, video, audio)
- `file`: The media file to upload
- `owner_id`: ID of the owner (defaults to current user)
- `business_id`: ID of the business

```
PUT /api/v1/media/:id
```
Updates an existing media. Supports multipart/form-data for file uploads.

Parameters:
- `media_type`: Type of media (image, video, audio)
- `file`: The media file to upload
- `owner_id`: ID of the owner
- `business_id`: ID of the business

```
DELETE /api/v1/media/:id
```
Deletes a specific media.

```
DELETE /api/v1/media
```
Bulk deletes media.

Parameters:
- `ids`: Array of media IDs to delete

### Slide Media Endpoints

```
GET /api/v1/slides/:slide_id/media
```
Returns a list of all media for a specific slide, ordered by the `order` field.

```
GET /api/v1/slide_media/:id
```
Returns details for a specific slide media.

```
POST /api/v1/slide_media
```
Creates a new slide media association.

Parameters:
- `slide_id`: ID of the slide
- `media_id`: ID of the media
- `order`: Order of the media within the slide (default: 0)
- `duration`: Duration in seconds to display the media (default: 5)
- `audio_media_id`: ID of the audio media to associate with the image media (optional)
- `qr_id`: ID of the QR code to associate with the media (optional)
- `description`: Description text for the media (optional)
- `text_size`: Size of the description text (optional)
- `description_position`: Position of the description (optional)

```
PUT /api/v1/slide_media/:id
```
Updates an existing slide media association.

Parameters:
- Same as POST

```
DELETE /api/v1/slide_media/:id
```
Deletes a specific slide media association.

```
POST /api/v1/slides/:slide_id/media/reorder
```
Reorders media within a slide.

Parameters:
- `order`: Array of media IDs in the desired order

## Usage Examples

### Upload an Image

```bash
curl -X POST http://localhost:9000/api/v1/media \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "media_type=image" \
  -F "file=@path/to/image.jpg" \
  -F "business_id=1"
```

### Upload an Audio

```bash
curl -X POST http://localhost:9000/api/v1/media \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "media_type=audio" \
  -F "file=@path/to/audio.mp3" \
  -F "business_id=1"
```

### Add Image Media to a Slide with Audio and QR

```bash
curl -X POST http://localhost:9000/api/v1/slide_media \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "slide_id": 1,
    "media_id": 2,
    "order": 0,
    "duration": 10,
    "audio_media_id": 3,
    "qr_id": 4,
    "description": "Image with audio and QR",
    "text_size": "medium",
    "description_position": "bottom"
  }'
```

### Reorder Media in a Slide

```bash
curl -X POST http://localhost:9000/api/v1/slides/1/media/reorder \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "order": [3, 2, 1]
  }'
```

## Testing

A test script `test_media_management.sh` is provided to verify the media management features. The script tests:

1. Media upload for different types (image, audio, video)
2. Adding media to slides with various attributes
3. Retrieving media for a slide
4. Reordering media within a slide
5. Updating slide media attributes
6. Owner-based access control
7. Admin access to all media
8. Deleting slide media

To run the test script:

```bash
bash test_media_management.sh
```

## Implementation Notes

### File Storage

Media files are stored in the `public/uploads` directory, organized by media type:
- Images: `public/uploads/images`
- Videos: `public/uploads/videos`
- Audio: `public/uploads/audios`

Files are given unique filenames to prevent collisions.

### Owner-Based Access Control

Media ownership is determined by:
1. Direct ownership (owner_id)
2. Business ownership (business_id)
3. Association with slides or playlists that belong to businesses owned by the user

Administrators can access and manage all media regardless of ownership.

### Audio for Images

Audio can only be associated with image media. The system validates that:
1. The media being associated with audio is of type 'image'
2. The audio media is of type 'audio'

### Media Ordering

Media within a slide is ordered by the `order` field. The reorder endpoint allows changing the order of media within a slide by providing an array of media IDs in the desired order.