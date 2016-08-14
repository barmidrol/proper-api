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

end