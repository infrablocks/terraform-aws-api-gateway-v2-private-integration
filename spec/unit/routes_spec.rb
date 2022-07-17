# frozen_string_literal: true

require 'spec_helper'

describe 'routes' do
  describe 'by default' do
    before(:context) do
      @plan = plan(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com'
        )
      end
    end

    it 'creates a route for the integration' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_route')
              .once)
    end
  end
end
