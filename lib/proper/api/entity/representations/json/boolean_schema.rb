class Respect::BooleanSchema::JSON

  #  Retrurns the URL to the attached image.
  #
  def represent(value, schema, options = {})
    if value.nil?
      if schema.options[:allow_nil] 
        return nil 
      else
        raise Respect::ValidationError
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
        raise Respect::ValidationError
      end
    end
    
    !!value
  end

end