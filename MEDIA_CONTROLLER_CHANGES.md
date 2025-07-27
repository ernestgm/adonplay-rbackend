# Media Controller Changes

## Overview

The Media Controller has been updated to support the following requirements:

1. Handle multiple files for audio and image types
2. Ensure video type still saves a single file
3. Store files in an FTP server with SSL
4. Create a specific directory structure for file storage: `env/medias/user_{id}/media_type/`

## Implementation Details

### 1. Added SFTP Support

- Added the `net-sftp` gem to the Gemfile
- Created an initializer file (`config/initializers/sftp_config.rb`) with:
  - SFTP connection configuration
  - Helper methods for uploading and deleting files
  - Environment mapping (Rails.env to 'desa' or 'prod')

### 2. Updated Media Controller

#### Create Method

- Added support for multiple file uploads via the `files` parameter
- Enforced the rule that video type can only have a single file
- Implemented the required directory structure: `env/medias/user_{id}/media_type/`
- Used the SFTP helper to upload files to the remote server
- Maintained backward compatibility with the `file` parameter for single file uploads
- Added proper error handling and cleanup of temporary files

#### Update Method

- Updated to use SFTP for file storage
- Implemented the required directory structure
- Added proper error handling and cleanup of temporary files

#### Destroy Method

- Updated to delete files from SFTP instead of the local filesystem
- Added error handling to continue with the deletion even if the SFTP delete fails

### 3. Media Params

- Updated to include `file_path` so that it can be updated when a new file is uploaded

## Usage

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

## SFTP Configuration

The SFTP connection is configured with the following parameters:
- `host`: The SFTP server host (default: 'localhost')
- `port`: The SFTP server port (default: 22)
- `username`: The SFTP server username (default: 'user')
- `password`: The SFTP server password (default: 'password')

These parameters can be overridden using environment variables:
- `SFTP_HOST`
- `SFTP_PORT`
- `SFTP_USERNAME`
- `SFTP_PASSWORD`