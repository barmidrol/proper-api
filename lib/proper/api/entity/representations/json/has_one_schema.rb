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

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_representer!( via, schema, from, to )
    var = ::Proper::Api::Entity.random_variable!
    code = "#{var} = #{from}\n"

    code << "if #{var}.nil?\n"
    code << "raise Respect::ValidationError.new\n" unless schema.allow_nil? 
    code << "#{ to } = nil\n" if schema.allow_nil?
    code << "else\n"
    code << schema.of.send( :compile_representer!, via, false, from, to )
    code << "end\n"

    code
  end

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_parser!( via, schema, from, to )
    var = ::Proper::Api::Entity.random_variable!
    code = "#{var} = #{from}\n"

    code << "if #{var}.nil?\n"
    code << "raise Respect::ValidationError.new\n" unless schema.allow_nil? 
    code << "#{ to } = nil\n" if schema.allow_nil?
    code << "else\n"
    code << schema.of.send( :compile_parser!, via, false, from, to )
    code << "end\n"

    code
  end

end