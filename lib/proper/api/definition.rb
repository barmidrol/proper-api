module Proper
  module Api

    #  This module implements DSL for anonymous modules created by controller's DSL
    #  and providing API schema information.
    #
    module Definition
      extend ActiveSupport::Concern

      module ClassMethods

        #  Yields the block and harvests the description into
        #  DESCRIPTION constant.
        #
        def description(&block)
          const_set(:DESCRIPTION, yield)
        end

        #  Defines the schema for the request parameters. It effectively
        #  defines Request class, includes ::Proper::Api::Entity module into it,
        #  invokes ::schema method and evaluates the block in the context of the
        #  schema builder.
        #
        def request_schema(&block)
          request_class = const_defined?(:Request) ? const_get(:Request) : const_set(:Request, Class.new { include ::Proper::Api::Entity })
          request_class.schema do |s|
            s.instance_eval(&block)
          end
        end

        #  Defines the blank request schema (yet creating Request class to keep consistency).
        #
        def blank_request_schema!
          request_schema {}
        end

        #  Defines the schema for the response parameters. It effectively
        #  defines Response class, includes ::Proper::Api::Entity module into it,
        #  invokes ::schema method and evaluates the block in the context of the
        #  schema builder.
        #
        def response_schema(constant = nil, &block)
          return const_set(:Response, constant) if constant

          response_class = const_defined?(:Response) ? const_get(:Response) : const_set(:Response, Class.new { include ::Proper::Api::Entity })
          response_class.schema do |s|
            s.instance_eval(&block)
          end
        end

        #  Defines the blank request schema (yet creating Request class to keep consistency).
        #
        def blank_response_schema!
          response_schema {}
        end

      end
      
    end

  end
end