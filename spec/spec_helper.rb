$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'proper/api'

::Proper::Api::Entity.do_the_magic = true
RSpec::Expectations.configuration.on_potential_false_positives = :nothing
