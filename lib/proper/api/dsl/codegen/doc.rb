module Proper
  module Api
    module Dsl
      module Codegen

        #  This class implements documentation generation.
        #
        class Doc < Base

          #  Contains a hash of controllers pointing to a set of endpoints
          attr_accessor :controllers

          #  Contains an array of entities (re-used across the calls)
          attr_accessor :entities

          #  Generates specific code's implementation of API calls and model messages.
          #
          def generate!(options = {})
            self.controllers = self.endpoints.group_by(&:controller)
            self.entities = self.models.reject { |model| model.name.end_with?("::Request") }.reject { |model| model.name.end_with?("::Response") }

            html = ERB.new(template_for("flavour")).result(binding)

            if options[:inline]
              html
            else
              write_file( "output.html" ) { |f| f << html }
            end
          end

          #  Returns template content for the name given.
          #
          def template_for(name, partial = false)
            File.open( File.expand_path("../templates/doc/#{ partial ? "_" : "" }#{name}.html.erb", __FILE__) ).read
          end

          #  Humanizes entity class name.
          #
          def humanize_entity_class(name)
            name.gsub(/.+\:\:Serialize\:\:/, "")
          end

          #  Returns description for an endpoint given.
          #
          def description_for(endpoint)
            markdown = operation_class( endpoint.options[:via], endpoint.action ).const_get(:DESCRIPTION) rescue endpoint.options[:via].const_get(:DESCRIPTION)
            markdown_to_html( markdown )
          end

          #  Renders markdown to html.
          #
          def markdown_to_html(markdown)
            Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true)).render(markdown)
          end

          #  Humanizes schema type.
          #
          def humanize_property_type(schema)
            Rails.logger.debug " = Humanizing description of #{schema.inspect}"

            example = {
              ::Respect::ArraySchema => '[ "An", "Array", "Of", "Strings" ]',
              ::Respect::BooleanSchema => 'true',
              ::Respect::DateSchema => Date.today.to_json,
              ::Respect::DatetimeSchema => Time.now.utc.to_json,
              ::Respect::InstantSchema => Time.now.utc.to_json,
              ::Respect::FloatSchema => (rand(1000).to_f / 10.0).inspect,
              ::Respect::IntegerSchema => rand(1000).inspect,
              ::Respect::StringSchema => '"Some string"'
            }[ schema.class ].to_s

            comment = [ schema.options[:doc] + "" ]

            if schema.options[:in]
              comment << "Allowed values are: #{ schema.options[:in].map(&:inspect).to_sentence }"
            end

            if schema.is_a?(::Respect::ArraySchema) && schema.item.options[:in]
              comment << "Allowed values are: #{ schema.item.options[:in].map(&:inspect).to_sentence }"
            end

            if schema.options[:allow_nil]
              comment << "Can be null"
            else
              comment << "Cannot be null"
            end

            return example, "// " + comment.join("<br />// ")
          end

          #  Renders the partial as a ERB template.
          #
          def render(partial, variables = {})
            Rails.logger.debug " = Rendering #{partial.inspect} with #{variables.inspect}"

            current_binding = binding

            variables.each do |name, value|
              current_binding.eval("#{name} = nil; lambda { |v| #{name} = v }").call(value)
            end

            ERB.new(template_for(partial, true)).result(current_binding)
          end

        end

      end
    end
  end
end