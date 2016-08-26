require_relative 'base'

module Proper
  module Api
    module Dsl
      module Codegen

        #  This class implements code generation routes for C# language.
        #
        class Ruby < ::Proper::Api::Dsl::Codegen::Base

          #  Contains base namespace for models.
          #
          def models_namespace
            options[:model_namespace].to_s
          end

          #  Contains base namespace for APIs.
          #
          def api_namespace
            options[:api_namespace].to_s
          end

        protected

          #  Converts model's namespace to C# one.
          #
          def sanitize_model_namespace( model )
            [ models_namespace, model.name.split("::")[0...-1] ].flatten.compact.join("::")
          end

          #  Converts model's class to C# one.
          #
          def sanitize_model_class( model )
            model.name.split("::").last
          end

          #  Converts API's namespace to C# one.
          #
          def sanitize_api_namespace( controller )
            [ api_namespace, controller.name.split("::")[0...-1] ].flatten.compact.join("::")
          end

          #  Converts API's class to C# one.
          #
          def sanitize_api_class( controller )
            controller.name.split("::").last
          end

          #  Sanitizes property name to follow C# conventions.
          #
          def sanitize_property_name( name )
            name.to_s
          end

          #  Sanitizes method name to follow C# conventions.
          #
          def sanitize_method_name( name )
            name.to_s
          end

          #  Returns fully qualified C# name for model class.
          #
          def ruby_model_fqn( model )
            [ sanitize_model_namespace(model), sanitize_model_class(model) ].compact.join("::")
          end

          #  Returns fully qualified C# name for controller class.
          #
          def ruby_api_fqn( controller )
            [ sanitize_api_namespace(controller), sanitize_api_class(controller) ].compact.join("::")
          end

          #  Emits class statements for the model.
          #
          def emit_model_class!( file, model, &block )
            emit_summary_comment!(file, model.description) unless (request_models.include?(model) || response_models.include?(model))

            file << "#{indent}class #{sanitize_model_namespace(model)}::#{ sanitize_model_class(model) }\n"
            
            @indent += 1

            file << "\n"
            file << "#{indent}include Proper::Api::Entity\n"
            file << "\n"
            yield
            @indent -= 1

            file << "#{indent}end\n"
          end

          #  Ensures an enum module with costants is present.
          #
          def emit_enum!( enum )
            module_name = ruby_model_fqn( enum.constantize )

            puts "Dumping enum #{enum}".green

            path = module_name[ models_namespace.size .. -1 ].split("::").select(&:present?).compact.map { |part| part.underscore }.join("/")
            path = "models/" + path + ".rb"

            ensure_all_modules_are_present!( module_name )

            write_file( path ) do |file|
              file << "module #{module_name}\n"

              from = enum.constantize
              from.constants.each do |const_name| 
                file << "  #{const_name} = #{from.const_get(const_name).inspect}\n"
              end

              file << "end\n"
            end
          end

          #  Emits fields for the model.
          #
          def emit_model_fields!( file, model )
            file << "#{indent}schema(fields: true) do\n"
            @indent += 1

            model.schema_definition.properties.each do |name, schema|
              emit_enum!( schema.options[:from] ) if schema.is_a?(Respect::EnumSchema)

              options         = schema.options.dup
              options[:of]    = ruby_model_fqn( options[:of].constantize ) if options.has_key?(:of)
              options[:from]  = ruby_model_fqn( options[:from].constantize ) if options.has_key?(:from)
              
              doc = options.delete(:doc)

              field_definition = schema.class.name.demodulize.underscore.gsub(/_schema$/, "")
              field_definition += " :#{name}, "
              field_definition += options.to_a.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")

              file << "#{ indent }# #{doc}\n"
              file << "#{ indent }#{ field_definition }\n"
            end

            @indent -= 1
            file << "#{indent}end\n"
            file << "\n"            
          end

          #  Emits API's class definition.
          #
          def emit_api_class!( file, controller )
            emit_summary_comment!(file, controller.const_get(:DESCRIPTION))

            file << "#{indent}class #{sanitize_api_namespace(controller)}::#{sanitize_api_class(controller)} < Proper::Api::Interop::Ruby::Controller\n\n"
            
            @indent += 1
            yield
            @indent -= 1

            file << "#{indent}end\n"
          end

          #  Emmits description comment into file provided.
          #
          def emit_summary_comment!(file, comment)
            comment.split("\n").each do |line|
              file << "#{indent}#  #{line.gsub(/^\s+/, "")}\n"
            end

            file << "#{indent}#\n"
          end

          #  Gets request class from the endpoint.
          #
          def extract_request_class( endpoint )
            endpoint.options[:via].const_get(:Request)
          end

          #  Gets request class from the endpoint.
          #
          def extract_response_class( endpoint )
            endpoint.options[:via].const_get(:Response)
          end

          #  Emits controller's methods.
          #
          def emit_api_methods!( file, controller, endpoints )
            endpoints.each do |endpoint|
              puts "  Dumping action #{endpoint.action} (#{ endpoint.path })".green

              request_class   = extract_request_class(endpoint)
              response_class  = extract_response_class(endpoint)

              request_class = request_class.nil? ? "" : ruby_model_fqn(request_class)
              response_class = response_class.nil? ? "" : ruby_model_fqn(response_class)

              signature = []
              signature << "request = nil" if request_class.present?

              description = endpoint.options[:via].const_get(:DESCRIPTION)
              
              emit_summary_comment!( file, description )

              request_class_model = extract_request_class(endpoint)
              response_class_model = extract_response_class(endpoint)

              if request_class_model
                file << "#{ indent }#  The request class fields are:\n"

                request_class_model.schema_definition.properties.each do |name, schema|
                  options         = schema.options.dup
                  options[:of]    = ruby_model_fqn( options[:of].constantize ) if options.has_key?(:of)
                  options[:from]  = ruby_model_fqn( options[:from].constantize ) if options.has_key?(:from)

                  doc = options.delete(:doc)

                  field_definition = schema.class.name.demodulize.underscore.gsub(/_schema$/, "")
                  field_definition += " :#{name}, "
                  field_definition += options.to_a.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")

                  file << "#{ indent }#    #{ field_definition }\n"
                end

                file << "#{ indent }#\n"
              end

              if response_class_model
                file << "#{ indent }#  The response class fields are:\n"

                response_class_model.schema_definition.properties.each do |name, schema|
                  options         = schema.options.dup
                  options[:of]    = ruby_model_fqn( options[:of].constantize ) if options.has_key?(:of)
                  options[:from]  = ruby_model_fqn( options[:from].constantize ) if options.has_key?(:from)

                  doc = options.delete(:doc)

                  field_definition = schema.class.name.demodulize.underscore.gsub(/_schema$/, "")
                  field_definition += " :#{name}, "
                  field_definition += options.to_a.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")

                  file << "#{ indent }#    #{ field_definition }\n"
                end

                file << "#{ indent }#\n"
              end

              file << "#{indent}def #{ sanitize_method_name( endpoint.action ) }(#{ signature.join(", ") })\n"
              file << "#{indent}  request = #{request_class}.parse( :json, request ) if request.is_a?(Hash)\n"
              file << "#{indent}  request = #{request_class}.new if request.nil?\n"
              file << "#{indent}  data = #{endpoint.method()}( #{ endpoint.path.inspect.gsub(":id", '" + request.id.to_s + "').gsub("(.:format)", ".json") }, request )\n"
              file << "#{indent}  #{response_class}.parse( :json, MultiJson.load(data) )\n"
              file << "#{indent}end\n\n"
            end
          end

          #  Dumps model file.
          #
          def dump_model( model )
            puts "Dumping model #{model.name}".green

            path = ruby_model_fqn(model)[ models_namespace.size .. -1 ].split("::").select(&:present?).compact.map { |part| part.underscore }.join("/")
            path = "models/" + path + ".rb"

            ensure_all_modules_are_present!( ruby_model_fqn(model) )

            write_file( path ) do |file|
              @indent = 0

              emit_model_class!( file, model ) do
                emit_model_fields!( file, model )
              end
            end
          end

          #  Dumps endpoint.
          #
          def dump_endpoints( controller, endpoints )
            puts "Dumping controller #{controller.name}".green

            path = ruby_api_fqn(controller)[ api_namespace.size .. -1 ].split("::").select(&:present?).map { |part| part.underscore }.join("/")
            path = "controllers/" + path + ".rb"

            ensure_all_modules_are_present!( ruby_api_fqn(controller) )

            write_file( path ) do |file|
              @indent = 0

              emit_api_class!( file, controller ) do
                emit_api_methods!( file, controller, endpoints )
              end
            end
          end

          #  In order to make Rails' autoloading happy, we need to define empty modules
          #  so that all intermediate constants are present.
          #
          def ensure_all_modules_are_present!( class_name )
            puts "Ensuring intermediate modules for #{class_name}".green

            @existing_class_map ||= begin 
              result =  self.models.map { |model| ruby_model_fqn(model) }
              result += self.endpoints.map { |endpoint| ruby_api_fqn(endpoint.controller) }
              result =  result.uniq.index_by(&:to_s)
            end

            class_name.split("::")[0...-1].inject("") do |module_name, part|
              name = [ module_name, part ].select(&:present?).join("::")
              path = "../" + name.underscore + ".rb"

              write_file( path ) do |file|
                parts = name.split("::")

                parts.inject("") do |indent, part|
                  file << "#{indent}module #{part.camelize}\n"
                  indent + "  "
                end

                parts.inject("  " * (parts.size - 1)) do |indent, part|
                  file << "#{indent}end\n"
                  indent[0...-2]
                end
              end

              name
            end
          end

          #  Returns current indent.
          #
          def indent
            "  " * @indent
          end

        end

      end
    end
  end
end