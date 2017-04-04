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

end