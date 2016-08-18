module Proper
  module Api
    module Dsl
      module Codegen

        #  This class is a base class for all code generators providing common
        #  routines and defining abstract callbacks that specific language implementation
        #  would follow to override.
        #
        class Base

          #  An array of endpoints to generate code for.
          attr_reader :endpoints

          #  A hash of options driving the codegen.
          attr_reader :options

          #  Constructs codegen class, memoizing endpoints to gather information from.
          #
          def initialize(endpoints, options = {})
            @options = options

            @endpoints = endpoints.select do |endpoint|
              if endpoint.options.nil? || !endpoint.options[:via].is_a?(Module)
                puts "Skipping #{endpoint.path.to_s.inspect}".red
                false
              else
                true
              end
            end.reject { |e| e.method == :patch }
          end

          #  Generates specific code's implementation of API calls and model messages.
          #
          def generate!
            self.models.each do |model|
              dump_model( model )
            end

            self.endpoints.group_by(&:controller).each do |controller, endpoints|
              dump_endpoints( controller, endpoints )
            end
          end

        protected

          #  Holds an array of all request models.
          #
          def request_models
            endpoints.map do |endpoint|
              endpoint.options[:via].const_get(:Request)
            end.compact
          end

          #  Holds an array of all reponse models.
          #
          def response_models
            endpoints.map do |endpoint|
              endpoint.options[:via].const_get(:Response)
            end.compact
          end

          #  Collects all models from all endpoints defined.
          #
          def models
            roots = endpoints.flat_map do |endpoint|
              [ 
                endpoint.options[:via].const_get(:Request),
                endpoint.options[:via].const_get(:Response)
              ]
            end.flatten

            roots.map { |root| extract_referenced_models(root) }.flatten.uniq
          end

          #  Dumps model file.
          #
          def dump_model( model )
            raise NotImplementedError.new
          end

          #  Dumps endpoint.
          #
          def dump_endpoints( controller, endpoints )
            raise NotImplementedError.new
          end

          #  Attempts to extract nested model definitions – the one referenced by
          #  has_one or has_many schema arguments.
          #
          def extract_referenced_models( model )
            referenced_models( model ) + referenced_models( model ).map { |ref| extract_referenced_models(ref) } + [ model ]
          end

          #  Returns an array of models referenced by the passed one.
          #
          def referenced_models( model )
            model.schema_definition.properties.values.select { |s| s.is_a?(Respect::HasOneSchema) || s.is_a?(Respect::HasManySchema) }.map(&:of)
          end

          #  mkdir -p for the specified path + open for write combined in one routine.
          #  Yields a file object which can be used for writing.
          #
          def write_file(relative_path, &block)
            folder, file = relative_path.split("/")[0...-1].join("/"), relative_path.split("/")[-1]
            FileUtils.mkdir_p( File.join( options[:folder], folder ) )
            File.open( File.join( options[:folder], folder, file ), "wb", &block )
          end

          #  Returns current indent.
          #
          def indent
            "    " * @indent
          end

          #  Outputs smth increasing the indent for the time of the block.
          #
          def indented(&block)
            @indent += 1
            yield
            @indent += 1
          end

        end

      end
    end
  end
end