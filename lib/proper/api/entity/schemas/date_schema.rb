module Respect

  #  This is the schema used to represent DateTime values in ISO 8601 format (proper one).
  #
  #  Usage example:
  #
  #  Respect::HashSchema.define do |s|
  #    s.date :created_at
  #  end
  #  
  class DateSchema < DatetimeSchema
  end

end