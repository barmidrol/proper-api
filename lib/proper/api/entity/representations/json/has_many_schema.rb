class Respect::HasManySchema::JSON

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    value.map { |v| schema.of.represent( :json, v, options ) }
  end

  #  Attempts to parse the passed string into Date object.
  #
  def parse(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    value.map { |v| schema.of.parse( :json, v, options ) }
  end

end