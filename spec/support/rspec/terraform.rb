require 'rspec/core'

require_relative 'terraform/matchers'

RSpec.configure do |config|
  config.include(RSpec::Terraform::Matchers)
end
