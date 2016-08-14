class Respect::IntegerSchema::JSON

  #  Retrurns the integer version of the passed value.
  #
  def represent(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError
      end
    end

    value.to_i
  end

  def parse(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError
      end
    end

    value.to_i
  end

end