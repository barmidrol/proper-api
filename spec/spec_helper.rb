$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'proper/api'

RSpec::Expectations.configuration.on_potential_false_positives = :nothing
