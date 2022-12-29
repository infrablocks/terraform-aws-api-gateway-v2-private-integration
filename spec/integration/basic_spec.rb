# frozen_string_literal: true

require 'spec_helper'

describe 'basic example' do
  before(:context) do
    apply(role: :basic)
  end

  after(:context) do
    destroy(
      role: :basic,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'integration' do
    before(:context) do
      @integration = api_gateway_v2_client.get_integration(
        api_id: output(role: :basic, name: 'api_id'),
        integration_id: output(role: :basic, name: 'integration_id')
      )
    end

    it 'creates an integration' do
      expect(@integration).not_to(be_nil)
    end

    it 'uses an integration type of HTTP_PROXY' do
      expect(@integration.integration_type).to(eq('HTTP_PROXY'))
    end

    it 'uses an integration method of ANY' do
      expect(@integration.integration_method).to(eq('ANY'))
    end

    it 'uses the configured integration URI' do
      expect(@integration.integration_uri)
        .to(eq(output(role: :basic, name: 'alb_listener_arn')))
    end

    it 'uses a connection type of VPC_LINK' do
      expect(@integration.connection_type).to(eq('VPC_LINK'))
    end

    it 'uses the created VPC link' do
      expect(@integration.connection_id)
        .to(eq(output(role: :basic, name: 'vpc_link_id')))
    end

    it 'uses TLS to communicate with the target' do
      expect(@integration.tls_config).not_to(be_nil)
    end

    it 'uses the provided server name for certificate verification' do
      expect(@integration.tls_config.server_name_to_verify)
        .to(eq('https://service.example.com'))
    end

    it 'includes no request parameter mappings' do
      expect(@integration.request_parameters).to(be_nil)
    end
  end

  describe 'routes' do
    before(:context) do
      @routes =
        output(role: :basic, name: 'routes').inject({}) do |acc, route_entry|
          acc.merge(route_entry[0] => api_gateway_v2_client.get_route(
            api_id: output(role: :basic, name: 'api_id'),
            route_id: route_entry[1]
          ))
        end
    end

    it 'creates a route for the integration' do
      expect(@routes.length).to(eq(1))
    end
  end

  describe 'VPC link' do
    let(:component) do
      var(role: :basic, name: 'component')
    end

    let(:deployment_identifier) do
      var(role: :basic, name: 'deployment_identifier')
    end

    before(:context) do
      subnet_ids = output(role: :basic, name: 'private_subnet_ids')
      @vpc_link =
        api_gateway_v2_client
        .get_vpc_links
        .items
        .select { |link| link.subnet_ids.to_set == subnet_ids.to_set }
        .first
    end

    it 'creates a VPC link in the subnets with the provided IDs' do
      expect(@vpc_link).not_to(be_nil)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'uses a name including the component and deployment identifier' do
      expect(@vpc_link.name)
        .to(match(/.*#{component}.*/))
      expect(@vpc_link.name)
        .to(match(/.*#{deployment_identifier}.*/))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'outputs the VPC link ID' do
      expect(@vpc_link.vpc_link_id)
        .to(eq(output(role: :basic, name: 'vpc_link_id')))
    end

    it 'uses the component and deployment identifier as tags' do
      expect(@vpc_link.tags)
        .to(eq(
              {
                'Component' => component,
                'DeploymentIdentifier' => deployment_identifier
              }
            ))
    end
  end

  describe 'VPC link default security group' do
    before(:context) do
      @security_group =
        security_group(
          output(role: :basic, name: 'vpc_link_default_security_group_id')
        )
    end

    it 'creates the default security group' do
      expect(@security_group).to(exist)
    end

    it 'has a single ingress rule' do
      expect(@security_group.inbound_rule_count).to(eq(1))
    end

    it 'has a single egress rule' do
      expect(@security_group.outbound_rule_count).to(eq(1))
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(@security_group.inbound)
        .to(be_opened(443)
              .protocol('tcp')
              .for('0.0.0.0/0'))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(@security_group)
        .to(have_outbound_rule(
              ip_protocol: 'all',
              from_port: '-1',
              to_port: '-1',
              ip_range: '0.0.0.0/0'
            ))
    end

    it 'uses the component and deployment identifier as tags' do
      expect(tag_map(@security_group))
        .to(eq(
              {
                'Component' => var(role: :basic, name: 'component'),
                'DeploymentIdentifier' =>
                  var(role: :basic, name: 'deployment_identifier')
              }
            ))
    end

    def tag_map(security_group)
      security_group
        .tags
        .inject({}) { |acc, tag| acc.merge(tag.key => tag.value) }
    end
  end
end
