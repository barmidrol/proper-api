require 'active_support/inflector'

class Respect::Schema

  #  Runs the validation against the value and returns a sanitized representation
  #  of the value passed.
  #
  def represent(via, object_or_hash, options = {})
    @via ||= {}
    @via[ via ] ||= self.class.const_get( via.to_s.classify ).new
    @via[ via ].represent( object_or_hash, self, options )
  end

  #  Attempts to parse passed data using schema definition.
  #
  def parse(via, data, options = {})
    @via ||= {}
    @via[ via ] ||= self.class.const_get( via.to_s.classify ).new
    @via[ via ].parse( data, self, options )
  end

end