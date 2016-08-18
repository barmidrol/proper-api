require "colorize"

require_relative 'dsl/codegen/csharp'
require_relative 'dsl/codegen/doc'
require_relative 'dsl/codegen/ruby'

module Proper
  module Api

    #  This module implements DSL for controllers to easily refer to operations provided
    #  by the engine.
    #
    module Dsl
      extend ActiveSupport::Concern

      class << self

        class Endpoint < Struct.new( :path, :method, :controller, :action, :options )

          #  Returns true if the route refers to a member action.
          #
          def member?
            path.include?(":id")
          end

        end

        #  Collects API definitions from all controllers sitting under a specific namespace.
        #
        def collect_api_definitions!( namespace )
          routes = Rails.application.routes.routes.select { |route| route.path.spec.to_s.start_with?(namespace) }
          
          method_map = {
            /^GET$/ => :get,
            /^PUT$/ => :put,
            /^POST$/ => :post,
            /^DELETE$/ => :delete,
            /^PATCH$/ => :patch
          }

          routes.map do |route|
            next if route.path.spec.to_s =~ /api\/unified\/docs/

            controller = (route.defaults[:controller] + "_controller").classify.constantize

            endpoint = Endpoint.new( 
              route.path.spec.to_s, 
              method_map[ route.constraints[:request_method] ],
              controller,
              route.defaults[:action],
              controller.apis[ route.defaults[:action].to_sym ]
            )
          end.compact
        end

      end

      #  Returns the entity class corresponding to request schema.
      #
      def request_schema(action)
        self.class.apis[ action ].via.const_get(:Request)
      end

      #  Returns the entity class corresponding to response schema.
      #
      def response_schema(action)
        self.class.apis[ action ].via.const_get(:Response)
      end

      module ClassMethods

        #  Holds modules / classes with the apis available (as a +Hash+ of action_name => implementation)
        attr_reader :apis

        #  Yields the block and harvests the description into
        #  DESCRIPTION constant.
        #
        def description(&block)
          const_set(:DESCRIPTION, yield)
        end

        #  Registers an action to be exposed to codegen/documentation API, as well as
        #  provides a stub implementation of a specific action.
        #
        #  The arguments are:
        #  * <tt>action</tt>:: Action name to register
        #  * <tt>&block</tt>:: The block which will be evaluated in the contex of an anonymous module
        #                      to gather API definitions quick and ez.
        #
        #  Sample usage is pretty straightforward:
        #
        #  class MyController < ApplicationController
        #    include ::Proper::Api::Dsl
        #
        #    provides :create do
        #      description { "Much useful description such wow" }
        #      
        #      request_schema do
        #        integer :id
        #      end
        #
        #      response_schema do
        #        string :name
        #      end
        #    end
        #
        #    def create
        #      render json: response_schema.represent({name: "My Very Name"})
        #    end
        #
        #
        def provides(action, &block)
          mod = Module.new

          mod.module_eval   { include ::Proper::Api::Definition }
          mod.module_eval   &block

          @apis ||= {}
          @apis[ action ] = {via: mod}

          const_set( action.to_s.classify, mod )
        end

      end
    end

  end
end