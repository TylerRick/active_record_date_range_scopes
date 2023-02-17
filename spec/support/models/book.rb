class Book < ActiveRecord::Base
  belongs_to :author

  # This defines created_between, created_after, created_before scopes
  date_range_scopes :created

  # This defines updated_between, updated_after, updated_before scopes
  date_range_scopes :updated
end
