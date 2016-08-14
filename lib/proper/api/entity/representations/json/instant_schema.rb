class Respect::InstantSchema::JSON

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    value.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  def parse(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    Time.parse( value )
  end

end