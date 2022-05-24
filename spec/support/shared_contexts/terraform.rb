# frozen_string_literal: true

require 'aws-sdk'
require 'awspec'
require 'ostruct'

require_relative '../terraform_module'

module RSpec
  module Terraform
    def configuration
      TerraformModule.configuration
    end

    def output_for(role, name)
      TerraformModule.output_for(role, name)
    end

    def provision(overrides = nil, &)
      TerraformModule.provision_for(:harness, overrides, &)
    end

    def destroy(overrides = nil, &)
      TerraformModule.destroy_for(:harness, overrides, force: true, &)
    end

    def reprovision(overrides = nil, &)
      destroy(overrides, &)
      provision(overrides, &)
    end
  end
end

# rubocop:disable RSpec/ContextWording
shared_context 'terraform' do
  include Awspec::Helper::Finder
  include RSpec::Terraform

  # rubocop:disable Style/OpenStructUse
  let(:vars) do
    OpenStruct.new(
      TerraformModule.configuration
          .for(:harness)
          .vars
    )
  end
  # rubocop:enable Style/OpenStructUse

  let(:api_gateway_v2_client) do
    Aws::ApiGatewayV2::Client.new
  end
end
# rubocop:enable RSpec/ContextWording
