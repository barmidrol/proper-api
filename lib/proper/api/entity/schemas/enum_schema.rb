module Respect

  #  This is the schema used to represent enumerable values.
  #  It's different from a regular string schema in a way that it's meant
  #  to be re-used by multiple entities.
  #
  #  Usage example:
  #
  #  Respect::HashSchema.define do |s|
  #    s.enum :type, from: My::Module::With::Constants
  #  end
  #  
  class EnumSchema < StringSchema

    #  Returns the module instance is enum is driven by.
    #
    def from
      @from ||= options[:from].constantize
    end

    #  Returns values available through this schema.
    #
    def values
      @values ||= from.constants.inject({}) do |memo, const_name| 
        memo.merge(const_name => from.const_get(const_name))
      end
    end

  end

end