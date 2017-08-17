class Respect::BooleanSchema::JSON

  #  Retrurns the URL to the attached image.
  #
  def represent(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil"
      end
    end

    !!value
  end

  #  Retrurns the URL to the attached image.
  #
  def parse(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil"
      end
    end
    
    !!value
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
    code << "#{ to } = !!#{ var }\n"
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
    code << "#{ to } = !!#{ var }\n"
    code << "end\n"

    code
  end

end