module Respect

  #  This is the schema used to represent DateTime values in ISO 8601 format (proper one).
  #
  #  Usage example:
  #
  #  Respect::InstantSchema.define do |s|
  #    s.instant :created_at
  #  end
  #  
  class InstantSchema < DatetimeSchema
  end

end