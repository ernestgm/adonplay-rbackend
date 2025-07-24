# CORS Configuration for Frontend Requests

## Changes Made

The Cross-Origin Resource Sharing (CORS) configuration has been modified to accept requests from the frontend application. The following changes were made:

1. Uncommented the CORS configuration in `config/initializers/cors.rb`
2. Set `origins "*"` to allow requests from any origin
3. Configured all resources to accept all common HTTP methods
4. Set `credentials: false` to indicate that credentials are not shared across origins

## Current Configuration

The current CORS configuration allows:
- Requests from any origin (`*`)
- All common HTTP methods (GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD)
- Any headers
- No credentials sharing

## Testing the Configuration

To test if the CORS configuration is working properly:

1. Start the Rails server:
   ```bash
   docker-compose up -d
   ```

2. From your frontend application, make a request to the API. For example:
   ```javascript
   fetch('http://localhost:9000/api/v1/users', {
     method: 'GET',
     headers: {
       'Content-Type': 'application/json',
       'Authorization': 'Bearer YOUR_TOKEN'
     }
   })
   .then(response => response.json())
   .then(data => console.log(data))
   .catch(error => console.error('Error:', error));
   ```

3. Check the browser's developer console. If there are no CORS-related errors, the configuration is working correctly.

## Production Considerations

The current configuration (`origins "*"`) is permissive and suitable for development environments. For production environments, it's recommended to:

1. Restrict the allowed origins to specific domains:
   ```ruby
   origins "https://your-frontend-domain.com", "https://another-allowed-domain.com"
   ```

2. Consider if credentials need to be shared:
   ```ruby
   credentials: true  # Only if you need to share cookies/auth across origins
   ```

3. Restart the server after making changes to the CORS configuration.

## Troubleshooting

If you encounter CORS issues:

1. Check the browser's developer console for specific error messages
2. Verify that the request includes the correct headers
3. Ensure the server is properly configured to handle preflight requests (OPTIONS)
4. Confirm that the frontend domain is included in the allowed origins (if not using `*`)

For more information on CORS, refer to:
- [MDN Web Docs: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [rack-cors gem documentation](https://github.com/cyu/rack-cors)