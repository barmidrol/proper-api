class Respect::FloatSchema::JSON

  #  Retrurns the float version of the passed value.
  #
  def represent(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil"
      end
    end

    value.to_f
  end

  #  Attempts to parse the passed string into Date object.
  #
  def parse(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError, "object is nil but this #{self.class} does not allow nil"
      end
    end

    value.to_f
  end

end