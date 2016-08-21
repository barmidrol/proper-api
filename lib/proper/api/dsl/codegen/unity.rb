require_relative 'base'

module Proper
  module Api
    module Dsl
      module Codegen

        #  This class implements code generation routes for C# language.
        #
        class Unity < ::Proper::Api::Dsl::Codegen::Csharp

        protected

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
              file << "#{indent}uri += \".json\";\n\n"

              file << "#{indent}var responseMessage = await ServiceClient.SendAsync( uri, System.Net.Http.HttpMethod.#{ endpoint.method.to_s.camelize }#{ request_class.present? ? ", request" : "" } );\n\n"

              file << "#{indent}if ( !String.IsNullOrEmpty( responseMessage.Data ) ) {\n"

              @indent += 1
              
              file << "#{indent}var result = JsonConvert.DeserializeObject<#{ response_class }>(responseMessage.Data, ServiceClient.JsonSerializerSettings);\n"
              file << "#{indent}result.StatusCode = responseMessage.StatusCode;\n"
              file << "#{indent}result.HttpStatusCode = responseMessage.HttpStatusCode;\n"
              file << "#{indent}return result;\n"

              @indent -= 1

              file << "#{indent}}\n\n"

              file << "#{indent}return new #{response_class} { StatusCode = responseMessage.StatusCode, HttpStatusCode = responseMessage.HttpStatusCode };"

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