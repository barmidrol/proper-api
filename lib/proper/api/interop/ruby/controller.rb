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
              begin
                RestClient.send( method, options[:url] + uri, entity.represent( options[:format] || :json ) )
              rescue RestClient::Exception => e
              end
            end
          end

        end

      end
    end
  end
end