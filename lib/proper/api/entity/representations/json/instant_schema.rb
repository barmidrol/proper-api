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

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_representer!( via, schema, from, to )
    var = ::Proper::Api::Entity.random_variable!
    code = "#{var} = #{from}\n"

    code << "if #{var}.nil?\n"
    code << "raise Respect::ValidationError.new(\"Found nil under \#{_field_name} for object \#{_object}\")\n" unless schema.allow_nil? 
    code << "#{to} = nil\n" if schema.allow_nil?
    code << "else\n"
    code << "#{ to } = #{ var }.utc.strftime('%Y-%m-%dT%H:%M:%SZ')\n"
    code << "end\n"

    code
  end

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_parser!( via, schema, from, to )
    var = ::Proper::Api::Entity.random_variable!
    code = "#{var} = #{from}\n"

    code << "if #{var}.nil?\n"
    code << "raise Respect::ValidationError.new(\"Found nil under \#{_field_name} for object \#{_object}\")\n" unless schema.allow_nil? 
    code << "#{ to } = nil\n" if schema.allow_nil?
    code << "else\n"
    code << "#{ to } = Time.parse( #{ var }.to_s )\n"
    code << "end\n"

    code
  end

end