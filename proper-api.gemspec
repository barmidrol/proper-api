# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proper/api/version'

Gem::Specification.new do |spec|
  spec.name          = "proper-api"
  spec.version       = Proper::Api::VERSION
  spec.authors       = ["Anton Zhuravsky"]
  spec.email         = ["mail2lf@gmail.com"]

  spec.summary       = %q{Proper API is a gem from writing proper API definitions.}
  spec.description   = %q{Proper API is a gem from writing proper API definitions. It supports strong typing, documentation generation, codegen for C# and Ruby, pluggable serializers and has almost no footprint on the Rails stack.}
  spec.homepage      = "https://github.com/yard/proper-api"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "respect"
  spec.add_dependency "colorize"
  spec.add_dependency "multi_json"
  spec.add_dependency "rest-client"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
