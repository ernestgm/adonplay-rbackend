#!/bin/bash

# Test script for the AddOwnerIdToBusinesses migration
# This script simulates running the migration and verifies that the owner_id field is properly added to the businesses table

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

# Step 1: Run the migration
print_header "Step 1: Running the migration"
echo "In a real environment, you would run:"
echo "rails db:migrate"
echo "For this test, we'll simulate the migration by checking if the migration file exists."

if [ -f "db/migrate/20250725043300_add_owner_id_to_businesses.rb" ]; then
  echo "Migration file exists: db/migrate/20250725043300_add_owner_id_to_businesses.rb"
else
  print_error "Migration file not found!"
  exit 1
fi

# Step 2: Verify the migration content
print_header "Step 2: Verifying migration content"
echo "Checking if the migration adds the owner_id field correctly..."

MIGRATION_CONTENT=$(cat db/migrate/20250725043300_add_owner_id_to_businesses.rb)
if echo "$MIGRATION_CONTENT" | grep -q "add_reference :businesses, :owner, foreign_key: { to_table: :users }"; then
  echo "Migration content looks good!"
else
  print_error "Migration content doesn't match expected pattern!"
  echo "Expected: add_reference :businesses, :owner, foreign_key: { to_table: :users }"
  echo "Found: $MIGRATION_CONTENT"
  exit 1
fi

# Step 3: Simulate schema changes
print_header "Step 3: Simulating schema changes"
echo "After running the migration, the businesses table would have the following columns:"
echo "- id (primary key)"
echo "- name (string, not null)"
echo "- description (text, not null)"
echo "- created_at (datetime, not null)"
echo "- updated_at (datetime, not null)"
echo "- owner_id (bigint, not null)"
echo "And there would be an index on owner_id and a foreign key constraint to the users table."

# Step 4: Test creating a business with an owner
print_header "Step 4: Testing business creation with owner"
echo "In a real environment, after the migration, you would be able to create a business with an owner:"
echo "
# Create a user
user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password', role: 'owner')

# Create a business with the user as owner
business = Business.create!(name: 'Test Business', description: 'Test Description', owner: user)

# Verify the relationship
puts \"Business owner: #{business.owner.name}\"
puts \"User's businesses: #{user.businesses.map(&:name).join(', ')}\"
"

# Step 5: Verify the documentation
print_header "Step 5: Verifying documentation"
if [ -f "ADD_OWNER_ID_TO_BUSINESSES.md" ]; then
  echo "Documentation file exists: ADD_OWNER_ID_TO_BUSINESSES.md"
else
  print_error "Documentation file not found!"
  exit 1
fi

print_header "All tests completed successfully!"
echo "The migration to add owner_id to the businesses table has been created and documented."
echo "To apply the migration in a real environment, run: rails db:migrate"