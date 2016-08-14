class Respect::HasOneSchema::JSON

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    schema.of.represent( :json, value, options )
  end

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def parse(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    schema.of.parse( :json, value, options )
  end

end