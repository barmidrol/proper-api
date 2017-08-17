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
    raise NotImplementedError.new
  end

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_representer!( via, schema, from, to )
    var = ::Proper::Api::Entity.random_variable!
    code = "#{var} = #{from}\n"
    
    code << "if #{var}.nil?\n"
    code << "raise Respect::ValidationError.new(\"Found nil under \#{_field_name} for object \#{_object}\")\n" unless schema.allow_nil? 
    code << "#{to} = nil\n" if schema.allow_nil?
    code << "else\n"
    code << "#{ to } = { latitude: #{ var }.latitude, longitude: #{ var }.longitude }\n"
    code << "end\n"

    code
  end

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_parser!( via, schema, from, to )
    raise NotImplementedError.new
  end

end