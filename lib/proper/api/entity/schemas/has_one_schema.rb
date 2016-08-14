module Respect

  #  This is the schema used to refer to a single object defined somewhere else.
  #
  #  Usage example:
  #
  #  Respect::HashSchema.define do |s|
  #    s.has_one :user, of: "My::User::Schema"
  #  end
  #
  #  The constrant supplied as the second argument is expected to respond to
  #  ::schema_definition method, which would be used to get the contents of the field.
  #  
  class HasOneSchema < CompositeSchema

    #  Returns entity class this element refers to.
    #
    def of
      @of ||= begin 
        if @options[:of].is_a?(String)
          @options[:of].constantize
        else
          @options[:of]
        end
      end
    end

    #  The schema definition of the has_one schema is obviously the schema of the
    #  <tt>of</ff> item.
    #
    def schema_definition
      of.schema_definition 
    end

  end

end