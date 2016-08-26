require_relative 'base'

module Proper
  module Api
    module Dsl
      module Codegen

        #  This class implements code generation routes for C# language.
        #
        class Csharp < ::Proper::Api::Dsl::Codegen::Base

        protected

          #  Contains base namespace for models.
          #
          def models_namespace
            options[:model_namespace]
          end

          #  Contains base namespace for APIs.
          #
          def api_namespace
            options[:api_namespace]
          end

          #  Converts model's namespace to C# one.
          #
          def sanitize_model_namespace( model )
            [ models_namespace, model.name.split("::")[0...-1] ].flatten.compact.join(".")
          end

          #  Converts model's class to C# one.
          #
          def sanitize_model_class( model )
            model.name.split("::").last
          end

          #  Converts API's namespace to C# one.
          #
          def sanitize_api_namespace( controller )
            [ api_namespace, controller.name.split("::")[1...-1] ].flatten.compact.join(".")
          end

          #  Converts API's class to C# one.
          #
          def sanitize_api_class( controller )
            controller.name.split("::").last
          end

          #  Sanitizes property name to follow C# conventions.
          #
          def sanitize_property_name( name )
            name.to_s.camelize 
          end

          #  Sanitizes enum value to be a valid C# value.
          #
          def sanitize_enum_value( value, const_module )
            if const_module
              const_module.constants.each do |constant|
                if const_module.const_get(constant) == value
                  value = constant.to_s.downcase
                  break
                end
              end
            end

            value.to_s.gsub(" ", "").camelize.gsub("::", "_")
          end

          #  Sanitizes method name to follow C# conventions.
          #
          def sanitize_method_name( name )
            name.to_s.camelize
          end

          #  Returns fully qualified C# name for model class.
          #
          def csharp_model_fqn( model )
            [ sanitize_model_namespace(model), sanitize_model_class(model) ].compact.join(".")
          end

          #  Returns fully qualified C# name for controller class.
          #
          def csharp_api_fqn( controller )
            [ sanitize_api_namespace(controller), sanitize_api_class(controller) ].compact.join(".")
          end

          #  Dumps model file.
          #
          def dump_model( model )
            puts "Dumping model #{model.name}".green

            path = csharp_model_fqn(model).gsub( models_namespace, "" ).gsub(/^\.?/, "").gsub(".", "/")
            path = "Models/" + path + ".designer.cs"

            write_file( path ) do |file|
              @indent = 0
              emit_model_usings!( file, model )

              emit_model_namespace!( file, model ) do
                emit_model_class!( file, model ) do
                  emit_model_fields!( file, model )
                end
              end
            end
          end

          #  Dumps endpoint.
          #
          def dump_endpoints( controller, endpoints )
            puts "Dumping controller #{controller.name}".green

            path = csharp_api_fqn(controller).gsub( api_namespace, "" ).gsub(/^\.?/, "").gsub(".", "/")
            path = "Controllers/" + path + ".designer.cs"

            write_file( path ) do |file|
              @indent = 0
              emit_api_usings!( file, controller )

              emit_api_namespace!( file, controller ) do
                emit_api_class!( file, controller ) do
                  emit_api_methods!( file, controller, endpoints )
                end
              end
            end
          end

          #  Emits namespace statements for the model.
          #
          def emit_model_namespace!( file, model, &block )
            file << "#{indent}namespace #{ sanitize_model_namespace(model) } {\n\n"
            
            @indent += 1
            yield
            @indent -= 1

            file << "\n"
            file << "#{indent}\n}"
          end

          #  Emits class statements for the model.
          #
          def emit_model_class!( file, model, &block )
            inheritance = if request_models.include?(model)
              " : App.Platform.Api.RequestMessage"
            elsif response_models.include?(model)
              " : App.Platform.Api.ResponseMessage"
            else
              ""
            end
              

            file << "#{indent}[DataContract]\n"
            file << "#{indent}public partial class #{ sanitize_model_class(model) }#{ inheritance } {\n\n"
            
            @indent += 1
            yield
            @indent -= 1

            file << "#{indent}}"
          end

          #  Returns C# type which corresponds to a specific schema definition.
          #
          def csharp_type_for_schema_definition( schema )
            type = {
              ::Respect::ArraySchema => "List<string>",
              ::Respect::BooleanSchema => "bool#{ schema.allow_nil? ? "?" : "" }",
              ::Respect::DatetimeSchema => "Instant#{ schema.allow_nil? ? "?" : "" }",
              ::Respect::InstantSchema => "Instant#{ schema.allow_nil? ? "?" : "" }",
              ::Respect::DateSchema => "LocalDate#{ schema.allow_nil? ? "?" : "" }",
              ::Respect::FloatSchema => "float#{ schema.allow_nil? ? "?" : "" }",
              ::Respect::HashSchema => "Dictionary<string, object>",
              ::Respect::IntegerSchema => "long#{ schema.allow_nil? ? "?" : "" }",
              ::Respect::StringSchema => "string",
              ::Respect::AnySchema => "object",
              ::Respect::GeoPointSchema => "global::App.Platform.Api.Fields.GeoPoint",
              ::Respect::AttachmentSchema => "global::App.Platform.Api.Fields.Attachment"
            }[ schema.class ]

            custom = nil
            collection = false

            if schema.is_a?(Respect::HasOneSchema)
              type = sanitize_model_namespace( schema.of ) + "." + sanitize_model_class( schema.of )
              custom = type
              collection = false
            end

            if schema.is_a?(Respect::EnumSchema)
              type = sanitize_model_namespace( schema.from ) + "." + sanitize_model_class( schema.from )
              custom = type
              collection = false

              emit_enum!( schema.from )
            end

            if schema.is_a?(Respect::HasManySchema)
              type = "List<" + sanitize_model_namespace( schema.of ) + "." + sanitize_model_class( schema.of ) + ">"
              custom = type
              collection = true
            end

            return type, custom, collection
          end

          #  Ensures an enum module with costants is present.
          #
          def emit_enum!( enum )
            module_name = sanitize_model_namespace( enum ) + "." + sanitize_model_class( enum )

            puts "Dumping enum #{enum}".green

            path = module_name.gsub( models_namespace, "" ).gsub(/^\.?/, "").gsub(".", "/")
            path = "Models/" + path + ".designer.cs"

            write_file( path ) do |file|
              file << "using System.Collections.Generic;\n"
              file << "using System.Runtime.Serialization;\n"

              file << "\n"
              file << "namespace #{ sanitize_model_namespace( enum ) } {\n"

              file << "    [DataContract]\n"
              file << "    public enum #{ sanitize_model_class( enum ) } {\n"

              enum.constants.each do |const_name| 
                value = enum.const_get( const_name )

                file << "        [EnumMember(Value = #{value.to_s.inspect})]\n"
                file << "        #{ sanitize_enum_value(value, enum) },\n"
              end

              file << "    }\n"

              file << "}\n"
            end
          end

          #  Emits fields for the model.
          #
          def emit_model_fields!( file, model )
            model.schema_definition.properties.each do |name, schema|
              next if name.to_sym == :id && request_models.include?(model)

              type, custom, collection = csharp_type_for_schema_definition(schema)

              #  Hash schemas require an inner class to be created
              if schema.is_a?(::Respect::HashSchema)
                type = name.to_s.camelize + "Hash"
                model_class = model.const_set(type, Class.new { define_singleton_method(:schema_definition) { schema } })

                emit_model_class!( file, model_class ) do
                  emit_model_fields!( file, model_class )
                end

                file << "\n\n"
              end

              emit_summary_comment!(file, schema.options[:doc]) if schema.options[ :doc ]

              file << "#{indent}[DataMember(Name=#{ name.to_s.inspect })]\n"
              file << "#{indent}public #{ type } #{ sanitize_property_name(name) } { get; set; }"
              file << "\n\n"
            end
          end

          def emit_summary_comment!(file, comment)
            file << "#{indent}// <summary>\n"
            comment.split("\n").each do |line|
              file << "#{indent}// #{line.gsub(/^\s+/, "")}\n"
            end
            file << "#{indent}// </summary>\n"
          end

          #  Emits to/from json routines as per model schema.
          #
          def emit_serializers!( file, model )
          end

          #  Emits using statements for the model.
          #
          def emit_model_usings!( file, model )
            namespaces = []

            namespaces << "System.Collections.Generic"
            namespaces << "System.Runtime.Serialization"
            namespaces << "NodaTime"

            namespaces.each do |ns|
              file << "#{indent}using #{ ns };\n"
            end

            file << "\n" if namespaces.any?
          end

          #  Emits using statements for the controller.
          #
          def emit_api_usings!( file, controller )
            namespaces = []

            namespaces << "System.Collections.Generic"
            namespaces << "System.Threading.Tasks"
            namespaces << "Newtonsoft.Json"
            namespaces << "System"

            namespaces.each do |ns|
              file << "#{indent}using #{ ns };\n"
            end

            file << "\n" if namespaces.any?
          end

          #  Emits API's namespace.
          #
          def emit_api_namespace!( file, controller )
            file << "#{indent}namespace #{ sanitize_api_namespace(controller) } {\n\n"
            
            @indent += 1
            yield
            @indent -= 1

            file << "\n"
            file << "#{indent}\n}"
          end

          #  Emits API's class definition.
          #
          def emit_api_class!( file, controller )
            emit_summary_comment!(file, controller.const_get(:DESCRIPTION))

            file << "#{indent}public partial class #{ sanitize_api_class(controller) } : App.Platform.Api.Controller {\n\n"
            
            @indent += 1
            yield
            @indent -= 1

            file << "\n"
            file << "#{indent}}"
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

              generic_request_task_param = response_class.nil? ? "" : "<#{ csharp_model_fqn(response_class) }>"
              task_class = "Task" + generic_request_task_param
              request_class = request_class.nil? ? "" : csharp_model_fqn(request_class)
              response_class = response_class.nil? ? "" : csharp_model_fqn(response_class)

              signature = []
              signature << "long id" if endpoint.member?
              signature << "#{request_class} request = null" if request_class.present?

              description = endpoint.options[:via].const_get(:DESCRIPTION)
              emit_summary_comment!(file, description)

              file << "#{indent}public async #{task_class} #{ sanitize_method_name( endpoint.action ) }Async(#{ signature.join(", ") }) {\n"
              @indent += 1
              
              file << "#{indent}request = request ?? new #{request_class}();\n" if request_class.present?
              file << "#{indent}string uri = #{ endpoint.path.inspect.gsub(":id", '" + System.String.Format("{0}", id) + "').gsub("(.:format)", "") };\n"
              file << "#{indent}uri += \".json\";\n"

              generic_params = [ request_class, response_class ].select(&:present?)
              file << "\n#{indent}#{ response_class.blank? ? "" : "return " }await ServiceClient.SendAsync#{ generic_params.present? ? "<" : "" }#{ generic_params.join(", ") }#{ generic_params.present? ? ">" : "" }( uri, System.Net.Http.HttpMethod.#{ endpoint.method.to_s.camelize }#{ request_class.present? ? ", request" : "" } );"

              @indent -= 1
              file << "\n"
              file << "#{indent}}\n\n"
            end
          end

        end

      end
    end
  end
end