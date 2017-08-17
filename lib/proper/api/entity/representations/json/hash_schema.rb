class Respect::HashSchema::JSON

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(object, schema, options = {})
    value_is_hash = object.is_a?(Hash)

    raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil" if object.nil? && !schema.allow_nil?
    return nil if object.nil?

    object = object.with_indifferent_access if value_is_hash

    schema.properties.inject({}) do |memo, (name, property_schema)|
      value = if getter = property_schema.options[:get]
        getter.call( object, options )
      elsif fname = property_schema.options[:from]
        value_is_hash ? object[ fname ] : object.send( fname )
      else
        value_is_hash ? object[ name ] : object.send( name )
      end

      memo[ name ] = property_schema.represent( :json, value, options.merge(name: name) )
      memo
    end
  end

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def parse(object, schema, options = {})
    raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil" if object.nil? && !schema.allow_nil?
    return nil if object.nil?

    object = object.with_indifferent_access

    schema.properties.inject({}) do |memo, (name, property_schema)|
      property_value = object[ name ]

      memo[ name ] = if setter = property_schema.options[:set]
        setter.call( property_value )
      else
        property_schema.parse( :json, property_value )
      end

      memo
    end
  end

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_representer!( via, schema, from, to )
    code = ""

    code << "if #{from}.is_a?(Hash)\n"
    code << compile_properties_representation!( via, schema, from, to, true, true )
    code << "else\n"
    code << compile_properties_representation!( via, schema, from, to, false, true )
    code << "end\n"

    code
  end

  #  Compiles properties' representation code using hash access variant if corresponding flag is set.
  #
  def compile_properties_representation!( via, schema, from, to, hash, out_hash )
    var = ::Proper::Api::Entity.random_variable!
    code = "#{var} = #{from}.try(:with_indifferent_access)\n"

    code << "if #{var}.nil?\n"
    code << "raise Respect::ValidationError.new(\"Found nil under \#{_field_name} for object \#{_object}\")\n" unless schema.allow_nil? 
    code << "#{to} = nil\n" if schema.allow_nil?
    code << "else\n"
    code << "_object = #{var}\n"

    schema.properties.inject({}) do |memo, (name, property_schema)|
      property_value_chunk = if getter = property_schema.options[:get]
        ::Proper::Api::Entity.store_proc!( getter ) + "[ #{var}, options ]"
      else fname = (property_schema.options[:from] || name)
        hash ? "#{var}[#{fname.inspect}]" : "#{var}.#{fname}"
      end

      code << "_field_name = #{ name.inspect }\n"
      code << property_schema.compile_representer!( via, property_value_chunk, "#{to}" + (out_hash ? "[#{name.inspect}]" : ".#{name}") )
    end

    code << "end\n"

    code
  end

  #  Compiles representer code that writes the value into +result+ variable.
  #
  def compile_parser!( via, schema, from, to )
    code = ""

    code << "if #{to}.is_a?(Hash)\n"
    code << compile_properties_representation!( via, schema, from, to, true, true )
    code << "else\n"
    code << compile_properties_representation!( via, schema, from, to, true, false )
    code << "end\n"

    code
  end

end