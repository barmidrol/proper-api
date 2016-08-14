namespace :proper do

  desc "This namespace contains routes to work with ::Proper::Api method definitions"
  namespace :api do

    desc "Creates code stubs using the language provided, as well as engine role"
    task(:codegen, [:language, :folder] => :environment) do |task, arguments|
      options = {
        folder:           arguments[:folder],

        model_namespace:  ENV["MODEL_NAMESPACE"] || "Models",
        api_namespace:    ENV["API_NAMESPACE"] || "Api",
      }

      endpoints = Proper::Api::Dsl.collect_api_definitions!( "/api" )
      Proper::Api::Dsl::Codegen.const_get( arguments[:language].classify ).new( endpoints, options ).generate!
    end

  end

end