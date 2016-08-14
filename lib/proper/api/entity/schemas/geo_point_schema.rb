module Respect

  #  This is the schema used to represent lat & lon coords.
  #
  #  Usage example:
  #
  #  Respect::HashSchema.define do |s|
  #    s.geo_point :location
  #  end
  #  
  class GeoPointSchema < DatetimeSchema
  end

end