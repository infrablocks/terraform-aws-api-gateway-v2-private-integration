# frozen_string_literal: true

require 'aws-sdk'
require 'awspec'

# rubocop:disable RSpec/ContextWording
shared_context 'awspec' do
  include Awspec::Helper::Finder

  def output(overrides = {}, &block)
    klass = Class.new do
      include RSpec::Terraform::Helpers
    end
    klass.new.output(overrides, &block)
  end

  let(:api_gateway_v2_client) do
    Aws::ApiGatewayV2::Client.new
  end
end
# rubocop:enable RSpec/ContextWording
