# frozen_string_literal: true

require 'aws-sdk'
require 'awspec'
require 'ostruct'
require 'ruby_terraform'

require_relative '../terraform_module'

module RSpec
  module Terraform
    def configuration
      TerraformModule.configuration
    end

    # rubocop:disable Style/OpenStructUse
    def vars(role)
      OpenStruct.new(configuration.for(role).vars)
    end
    # rubocop:enable Style/OpenStructUse

    def output(role, name)
      TerraformModule.output(role, name)
    end

    def plan(role, overrides = nil, &)
      RubyTerraform::Models::Plan.new(
        TerraformModule.plan(role, overrides, &)
      )
    end

    def provision(role, overrides = nil, &)
      TerraformModule.provision(role, overrides, &)
    end

    def destroy(role, overrides = nil, &)
      TerraformModule.destroy(role, overrides, force: true, &)
    end

    def reprovision(role, overrides = nil, &)
      destroy(role, overrides, &)
      provision(role, overrides, &)
    end
  end
end

# rubocop:disable RSpec/ContextWording
shared_context 'terraform' do
  include Awspec::Helper::Finder
  include RSpec::Terraform

  let(:api_gateway_v2_client) do
    Aws::ApiGatewayV2::Client.new
  end
end
# rubocop:enable RSpec/ContextWording
