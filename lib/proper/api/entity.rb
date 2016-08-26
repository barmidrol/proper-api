require 'active_support/concern'

require_relative "entity/schemas/has_one_schema"
require_relative "entity/schemas/has_many_schema"
require_relative "entity/schemas/instant_schema"
require_relative "entity/schemas/attachment_schema"
require_relative "entity/schemas/date_schema"
require_relative "entity/schemas/geo_point_schema"
require_relative "entity/schemas/enum_schema"

require_relative "entity/representations/schema"
require_relative "entity/representations/json"
require_relative "entity/representations/msgpack"

module Proper
  module Api

    #  This module provides support methods for defining entities for request
    #  and response messages.
    #
    module Entity

      extend ActiveSupport::Concern

      #  Represents the given data using the strategy supplied as +via+ param.
      #
      def represent(via, options = {})
        self.class.represent( via, self, options )
      end

      module ClassMethods

        #  Holds the reference to Respect schema of this entity.
        attr_reader :schema_definition

        #  Represents the given data using the strategy supplied as +via+ param.
        #
        def represent(via, object_or_hash, options = {})
          @schema_definition.represent( via, object_or_hash, options )
        end

        #  Represents the given data using the strategy supplied as +via+ param.
        #
        def parse(via, data, options = {}, object = nil)
          data = data.to_unsafe_hash if data.respond_to?(:to_unsafe_hash) 
          hash = @schema_definition.parse( via, data, options )

          return hash if object == {}

          hash.inject(object || self.new) do |obj, (name, value)|
            obj.send("#{name}=", value)
            obj
          end
        end

        #  This field is used to define schema for the entity. The <tt>schema</tt>
        #  object passed down is an instance of HashSchema.
        #
        def schema(options = {}, &block)
          @schema_definition = Respect::HashSchema.define { |s| s.instance_eval(&block) }
          if options[:fields]
            @schema_definition.properties.each do |name, options|
              attr_accessor name
            end
          end
        end

        #  Memoizes entity description
        def description(&block)
          if block_given?
            @description = yield
          else
            @description
          end
        end

      end

    end

  end
end