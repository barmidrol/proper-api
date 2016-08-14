class Respect::DateSchema::JSON

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    value.to_date.strftime("%Y-%m-%d")
  end

  #  Attempts to parse the passed string into Date object.
  #
  def parse(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    Date.parse(value)
  end

end