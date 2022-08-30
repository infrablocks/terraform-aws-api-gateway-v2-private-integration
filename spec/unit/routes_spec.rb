# frozen_string_literal: true

require 'spec_helper'

describe 'routes' do
  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
      end
    end

    it 'creates a route for the integration' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_route')
              .once)
    end
  end
end
