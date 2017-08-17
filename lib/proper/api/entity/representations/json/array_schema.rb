class Respect::ArraySchema::JSON

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil"
      end
    end

    raise Respect::ValidationError, "object is not an array, and ArraySchema expects it to be a collection" if (!value.nil? && !value.is_a?(Array))

    value.map do |entry|
      if entry.respond_to?(:represent)
        entry.represent(:json, options)
      else
        entry
      end
    end
  end

  def parse(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil"
      end
    end

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

    var2 = ::Proper::Api::Entity.random_variable!

    code << "#{to} = #{var}.map do |#{var2}|\n"
    code << "#{var2}.respond_to?(:represent) ? #{var2}.represent( :json, options ) : #{var2}\n"
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
    code << "raise Respect::ValidationError.new(\"Found nil under \#{_field_name} for object \#{_object}\")\n" unless schema.allow_nil? 
    code << "#{to} = nil\n" if schema.allow_nil?
    code << "else\n"

    var2 = ::Proper::Api::Entity.random_variable!

    code << "#{to} = #{var}.map do |#{var2}|\n"
    code << "#{var2}\n"
    code << "end\n"

    code << "end\n"

    code
  end

end