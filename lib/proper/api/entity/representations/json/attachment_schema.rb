class Respect::AttachmentSchema::JSON

  #  Retrurns the URL to the attached image.
  #
  def represent(value, schema, options = {})
    return nil if schema.options[:allow_nil] && value.nil?
    value.url
  end

  #  Retrurns the URL to the attached image.
  #
  def parse(value, schema, options = {})
    value
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
    code << "#{ to } = #{ var }.url\n"
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
    code << "#{to} = nil\n" if schema.allow_nil?
    code << "else\n"
    code << "#{ to } = #{ var }\n"
    code << "end\n"

    code
  end

end