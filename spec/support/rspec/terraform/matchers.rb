require_relative './matchers/include_resource_creation'

module RSpec
  module Terraform
    module Matchers
      def include_resource_creation(definition = {})
        IncludeResourceCreation.new(definition)
      end
    end
  end
end
