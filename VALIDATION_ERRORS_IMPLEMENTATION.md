# Validation Errors Implementation

## Overview

This document summarizes the changes made to implement detailed validation error messages for each field in the models. The implementation allows the API to return a structured JSON response with the field name and the error message for each validation error, so the frontend can display the error next to the appropriate field.

## Changes Made

### Models Updated

The following models were updated to include custom validation messages:

1. **User Model**
   - Added `messages` method to provide custom error messages for name, email, role, password, phone, and enabled fields

2. **Business Model**
   - Added `messages` method to provide custom error messages for name and description fields

3. **Device Model**
   - Added `messages` method to provide custom error messages for name, device_id, qr_id, marquee_id, and slide_id fields

4. **Marquee Model**
   - Added `messages` method to provide custom error messages for name, message, background_color, text_color, and business_id fields

5. **Media Model**
   - Added `messages` method to provide custom error messages for media_type and file_path fields

6. **Playlist Model**
   - Added `messages` method to provide custom error messages for name, slide_id, and qr_id fields

7. **QR Model**
   - Added `messages` method to provide custom error messages for name, info, position, and business_id fields

8. **Slide Model**
   - Added `messages` method to provide custom error messages for name and business_id fields

### Error Formatter Concern

Created a new concern called `ErrorFormatter` with a method `format_errors` that formats validation errors in a structured way. The method takes a record with errors and returns a hash where the keys are the field names and the values are arrays of error objects, each containing the error type and message.

```ruby
module ErrorFormatter
  # Format validation errors to return a structured JSON response
  # that includes the field name and the error message for each validation error
  def format_errors(record)
    return {} unless record.errors.any?
    
    # Get custom messages from the model if available
    custom_messages = record.respond_to?(:messages) ? record.messages : {}
    
    errors = {}
    record.errors.each do |error|
      attribute = error.attribute.to_s
      error_type = error.type.to_s
      
      # Try to find a custom message for this error
      message_key = "#{attribute}.#{error_type}"
      message = custom_messages[message_key] || error.full_message
      
      # Add the error to the errors hash
      errors[attribute] ||= []
      errors[attribute] << {
        type: error_type,
        message: message
      }
    end
    
    errors
  end
end
```

### Controllers Updated

The following controllers were updated to include the `ErrorFormatter` concern and use the `format_errors` method to return structured error responses:

1. **UsersController**
2. **BusinessesController**
3. **DevicesController**
4. **MarqueesController**
5. **MediaController**
6. **PlaylistsController**
7. **QrsController**
8. **SlidesController**

### Testing

A new test script `test_validation_errors.sh` was created to verify the validation error messages. The script tests four scenarios:

1. Creating a user with missing required fields
2. Creating a business with missing required fields
3. Creating a media with an invalid media_type
4. Updating a user with an invalid email format

For each test, it checks if the response contains structured error messages with the field name and the custom error message.

### Documentation

The API documentation was updated to reflect the new error response format. A new section called "Error Handling" was added that explains the new format and provides examples of error responses.

## Benefits

1. **Improved User Experience**: The frontend can now display specific error messages next to the appropriate fields, making it easier for users to understand and fix validation errors.

2. **Structured Error Responses**: The API now returns a structured JSON response with the field name and the error message for each validation error, making it easier for the frontend to process and display the errors.

3. **Customized Error Messages**: The error messages are now customized for each field and validation rule, making them more user-friendly and specific.

4. **Consistent Error Handling**: All controllers now use the same error handling approach, making the API more consistent and easier to maintain.

## How to Test

Run the `test_validation_errors.sh` script to verify that the API returns structured error responses with field names and error messages when validation errors occur:

```bash
bash test_validation_errors.sh
```

## Note

The implementation follows the example provided in the issue description, where each model has a `messages` method that returns a hash of custom error messages for different validation rules. The `ErrorFormatter` concern then uses these custom messages when formatting validation errors.