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
        getter.call( object )
      elsif fname = property_schema.options[:from]
        value_is_hash ? object[ fname ] : object.send( fname )
      else
        value_is_hash ? object[ name ] : object.send( name )
      end

      memo[ name ] = property_schema.represent( :json, value, name: name )
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

end