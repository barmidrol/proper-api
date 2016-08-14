class Respect::GeoPointSchema::JSON

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    { latitude: value.latitude, longitude: value.longitude }
  rescue Respect::ValidationError => ex
    Rails.logger.error "Cannot represent #{value.inspect} found in #{options[:__name__].inspect}: #{ex.message}"
    raise
  end

  #  Attempts to parse the passed string into Date object.
  #
  def parse(value, schema, options = {})
    raise NotImplementedError 
  end

end