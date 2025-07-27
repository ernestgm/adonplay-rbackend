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
      errors[attribute] << message
    end
    
    errors
  end
end