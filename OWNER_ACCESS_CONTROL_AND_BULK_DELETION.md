# Owner Access Control and Bulk Deletion

## Overview

This document describes the implementation of owner-based access control and bulk deletion functionality in the API. These changes ensure that users with the "owner" role can only access and modify their own entities, and that all entity controllers support bulk deletion.

## Owner-Based Access Control

### Business Ownership Model

The system now has a clear ownership model:

1. Each `Business` belongs to a `User` (owner)
2. Other entities (`Slide`, `Marquee`, `QR`, etc.) belong to a `Business`
3. Ownership of entities is determined through their association with a `Business`

### Access Control Rules

The following rules are enforced for users with the "owner" role:

1. Owners can only view, update, and delete businesses they own
2. Owners can only view, update, and delete entities (slides, marquees, QRs, etc.) that belong to businesses they own
3. Owners can only create entities for businesses they own

Users with the "admin" role can access and modify all entities regardless of ownership.

### Implementation Details

The access control is implemented through:

1. The `Authorizable` concern, which provides methods to check ownership and scope queries
2. Before actions in controllers to verify ownership before allowing access
3. Custom methods to verify ownership through associations

## Bulk Deletion

All entity controllers now support bulk deletion, allowing multiple entities to be deleted in a single request.

### Bulk Deletion Endpoints

The following endpoints support bulk deletion:

```
DELETE /api/v1/businesses
DELETE /api/v1/devices
DELETE /api/v1/marquees
DELETE /api/v1/media
DELETE /api/v1/playlists
DELETE /api/v1/qrs
DELETE /api/v1/slides
DELETE /api/v1/users
```

### Request Format

To delete multiple entities, send a DELETE request with a JSON body containing an array of IDs:

```json
{
  "ids": [1, 2, 3]
}
```

### Response Format

The response will include a message and the number of entities deleted:

```json
{
  "message": "3 entities deleted successfully",
  "deleted_count": 3
}
```

### Owner-Based Filtering

For users with the "owner" role, the bulk deletion endpoints will only delete entities that the user owns. Any IDs for entities the user doesn't own will be ignored.

For example, if an owner sends a request to delete slides with IDs 1, 2, and 3, but only owns slides 1 and 3, only slides 1 and 3 will be deleted, and the response will indicate that 2 slides were deleted.

## Testing

A test script `test_owner_access_control.sh` is provided to verify the owner-based access control and bulk deletion functionality. The script tests:

1. That owners cannot access, update, or delete entities they don't own
2. That owners can bulk delete their own entities
3. That owners can only delete their own entities in a mixed bulk deletion request
4. That admins can access and modify any entity
5. That admins can bulk delete entities from any owner

## API Usage Examples

### Bulk Delete Businesses (Admin)

```bash
curl -X DELETE http://localhost:9000/api/v1/businesses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{"ids": [1, 2, 3]}'
```

### Bulk Delete Businesses (Owner)

```bash
curl -X DELETE http://localhost:9000/api/v1/businesses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_OWNER_TOKEN" \
  -d '{"ids": [1, 2, 3]}'
```

Note: For owners, only businesses they own will be deleted.

### Create Entity for a Business (Owner)

```bash
curl -X POST http://localhost:9000/api/v1/slides \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_OWNER_TOKEN" \
  -d '{"name": "My Slide", "business_id": 1}'
```

Note: Owners can only create entities for businesses they own.

## Benefits

1. **Security**: Ensures that users can only access and modify their own data
2. **Efficiency**: Allows bulk operations to be performed in a single request
3. **Consistency**: All entity controllers follow the same pattern for access control and bulk deletion
4. **Flexibility**: Admins can still access and modify all data when necessary