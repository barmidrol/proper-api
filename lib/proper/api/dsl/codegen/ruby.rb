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
            [ api_namespace, controller.name.split("::")[1...-1] ].flatten.compact.join("::")
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
            inheritance = if request_models.include?(model)
              " < Proper::Api::Interop::Ruby::RequestMessage"
            elsif response_models.include?(model)
              " < Proper::Api::Interop::Ruby::ResponseMessage"
            else
              ""
            end
              
            file << "#{indent}class #{ model }#{ inheritance }\n"
            
            @indent += 1

            file << "\n"
            file << "#{indent}include Proper::Api::Entity\n"
            file << "\n"
            yield
            @indent -= 1

            file << "#{indent}end\n"
          end

          #  Emits fields for the model.
          #
          def emit_model_fields!( file, model )
            file << "#{indent}schema(fields: true) do\n"
            @indent += 1

            model.schema_definition.properties.each do |name, schema|
              field_definition = schema.class.name.demodulize.underscore.gsub(/_schema$/, "")
              field_definition += " :#{name}, "
              field_definition += schema.options.inspect

              file << "#{ indent }#{ field_definition }\n"
            end

            @indent -= 1
            file << "#{indent}end\n"
            file << "\n"            
          end

          #  Dumps model file.
          #
          def dump_model( model )
            puts "Dumping model #{model.name}".green

            path = ruby_model_fqn(model).gsub( models_namespace, "" ).split("::").compact.map { |part| part.underscore }.join("/")
            path = "models" + path + ".rb"

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
          end

          #  mkdir -p for the specified path + open for write combined in one routine.
          #  Yields a file object which can be used for writing.
          #
          def write_file(relative_path, &block)
            puts relative_path
            yield STDOUT
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