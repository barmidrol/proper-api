require 'rest-client'

module Proper
  module Api
    module Interop
      module Ruby

        #  This is the base class for all API controllers to communicate with Proper::Api.
        #
        class Controller

          #  Holds options passed during the initialization.
          attr_reader :options

          #  Creates a new instance of API controller.
          #
          def initialize(options = {})
            @options = options
          end

          %w(get post put delete).each do |method|
            define_method( method ) do |uri, entity|
              perform_request( method, options[:url] + uri, entity.represent( options[:format] || :json ) )
            end
          end

          #  Performs the request against a remote server.
          #
          def perform_request(method, url, data)
            response = if method.to_sym == :get
              ::RestClient.send( method, url, cookies: @cookies )
            else
              ::RestClient.send( method, url, data, cookies: @cookies )
            end
            
            @cookies = response.try(:cookies)

            response.body
          end

        end

      end
    end
  end
end