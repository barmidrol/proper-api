module Proper
  module Api
    class Railtie < Rails::Railtie
      rake_tasks do
        load File.expand_path('../../../tasks/codegen.rake', __FILE__)
      end
    end
  end
end