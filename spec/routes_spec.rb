# frozen_string_literal: true

require 'spec_helper'

describe 'routes' do
  let(:output_routes) do
    output(:root, 'routes')
  end

  let(:routes) do
    output_routes.inject({}) do |acc, route_entry|
      acc.merge(route_entry[0] => api_gateway_v2_client.get_route(
        api_id: output(:prerequisites, 'api_id'),
        route_id: route_entry[1]
      ))
    end
  end

  before(:context) do
    provision(:root) do |vars|
      vars.merge(
        include_vpc_link: false,
        vpc_link_id: output(:prerequisites, 'vpc_link_id'),
        tls_server_name_to_verify: 'example.com'
      )
    end
  end

  after(:context) do
    destroy(:root) do |vars|
      vars.merge(
        include_vpc_link: false,
        vpc_link_id: output(:prerequisites, 'vpc_link_id'),
        tls_server_name_to_verify: 'example.com'
      )
    end
  end

  describe 'by default' do
    it 'creates a route for the integration' do
      expect(routes.length).to(eq(1))
    end
  end
end
