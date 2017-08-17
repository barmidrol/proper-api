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

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_representer!( via, schema, from, to )
    var = ::Proper::Api::Entity.random_variable!
    code = "#{var} = #{from}\n"
    
    code << "if #{var}.nil?\n"
    code << "raise Respect::ValidationError.new\n" unless schema.allow_nil? 
    code << "#{to} = nil\n" if schema.allow_nil?
    code << "else\n"
    var2 = ::Proper::Api::Entity.random_variable!
    var3 = ::Proper::Api::Entity.random_variable!
    code << "#{to} = #{var}.map do |#{var2}|\n"
    code << "#{var3} = {}\n"
    code << schema.of.send( :compile_representer!, via, false, "#{var2}", "#{var3}" )
    code << "#{var3}\n"
    code << "end\n"
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
    code << "#{to} = nil\n" if schema.allow_nil?
    code << "else\n"
    var2 = ::Proper::Api::Entity.random_variable!
    var3 = ::Proper::Api::Entity.random_variable!
    code << "#{to} = #{var}.map do |#{var2}|\n"
    code << "#{var3} = {}\n"
    code << schema.of.send( :compile_parser!, via, false, "#{var2}", "#{var3}" )
    code << "#{var3}\n"
    code << "end\n"
    code << "end\n"

    code
  end

end