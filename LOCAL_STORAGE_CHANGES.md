# Media Controller Local Storage Changes

## Overview

The Media Controller has been updated to store files locally instead of using FTP. This change was implemented to simplify the deployment and maintenance of the application.

## Implementation Details

### 1. Added Local Storage Configuration

- Created a new initializer file (`config/initializers/local_storage_config.rb`) with:
  - Local storage configuration (base directory and environment mapping)
  - Helper methods for uploading and deleting files
  - Environment mapping (Rails.env to 'desa' or 'prod')

### 2. Updated Media Controller

#### Create Method

- Updated to use local storage instead of FTP
- Maintained the same directory structure: `env/medias/user_{id}/media_type/`
- Files are now stored in the `public/uploads` directory by default
- Maintained support for multiple file uploads for image and audio types
- Maintained the rule that video type can only have a single file

#### Update Method

- Updated to use local storage for file storage
- Maintained the same directory structure
- Added proper error handling and cleanup of temporary files

#### Destroy Method

- Updated to delete files from local storage instead of FTP
- Added error handling to continue with the deletion even if the local storage delete fails

### 3. Directory Structure

The directory structure for storing files remains the same:
```
public/uploads/
└── env (desa or prod)
    └── medias
        └── user_{id}
            └── media_type (images, videos, audio)
                └── filename
```

## Usage

The API endpoints and parameters remain the same:

### Creating Media with Multiple Files

```
POST /api/v1/media
```

Parameters:
- `media_type`: The type of media (image, video, audio)
- `files[]`: An array of files to upload (for image and audio types)
- `file`: A single file to upload (for backward compatibility or video type)

### Updating Media

```
PUT /api/v1/media/:id
```

Parameters:
- `media_type`: The type of media (optional, will use existing if not provided)
- `file`: The file to upload

### Deleting Media

```
DELETE /api/v1/media/:id
```

or for bulk deletion:

```
DELETE /api/v1/media
```

Parameters:
- `ids[]`: An array of media IDs to delete

## Environment Configuration

The environment ('desa' or 'prod') is determined based on the Rails environment:
- 'desa' for development, test, and staging environments
- 'prod' for production environment

## Local Storage Configuration

The local storage is configured with the following parameters:
- `base_dir`: The base directory for storing files (default: 'public/uploads')
- `environment`: The environment ('desa' or 'prod')

These parameters can be overridden using environment variables:
- `LOCAL_STORAGE_BASE_DIR`: The base directory for storing files

## Testing

A test script (`test_local_storage.sh`) has been provided to verify the local storage implementation. The script includes tests for:
1. Creating a media record with a file
2. Verifying the file exists in the local storage directory
3. Updating the media record with a new file
4. Deleting the media record

To use the script, customize it with actual values for:
- YOUR_TOKEN_HERE: A valid authentication token
- test_image.jpg and test_image2.jpg: Actual image files for testing
- YOUR_USER_ID: The ID of the user creating the media
- YOUR_MEDIA_ID: The ID of the media record to update/delete