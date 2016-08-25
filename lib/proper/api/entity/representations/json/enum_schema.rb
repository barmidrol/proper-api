class Respect::EnumSchema::JSON

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

    raise Respect::ValidationError, "value is #{value.inspect} but this #{self.class} only allows #{ schema.values.values.inspect }" if !value.nil? && !schema.values.values.include?( value )

    value
  end

  def parse(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError, "object is nil but this this #{self.class} does not allow nil"
      end
    end

    raise Respect::ValidationError, "value is #{value.inspect} but this #{self.class} only allows #{ schema.values.values.inspect }" if !value.nil? && !schema.values.values.include?( value )

    value
  end

end