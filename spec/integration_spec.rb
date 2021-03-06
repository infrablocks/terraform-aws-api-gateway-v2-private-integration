# frozen_string_literal: true

require 'spec_helper'

describe 'integration' do
  let(:alb_listeners) do
    output(:prerequisites, 'alb_listeners')
  end

  let(:integration_uri) do
    alb_listeners[:default][:arn]
  end

  let(:output_vpc_link_id) do
    output(:root, 'vpc_link_id')
  end

  let(:integration) do
    api_gateway_v2_client.get_integration(
      api_id: output(:prerequisites, 'api_id'),
      integration_id: output(:root, 'integration_id')
    )
  end

  def tls_server_name_to_verify
    'example.com'
  end

  describe 'by default' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify:
        )
      end
    end

    after(:context) do
      destroy(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify:
        )
      end
    end

    it 'creates an integration' do
      expect(integration).not_to(be_nil)
    end

    it 'uses an integration type of HTTP_PROXY' do
      expect(integration.integration_type).to(eq('HTTP_PROXY'))
    end

    it 'uses an integration method of ANY' do
      expect(integration.integration_method).to(eq('ANY'))
    end

    it 'uses the provided integration URI' do
      expect(integration.integration_uri)
        .to(eq(integration_uri))
    end

    it 'uses a connection type of VPC_LINK' do
      expect(integration.connection_type).to(eq('VPC_LINK'))
    end

    it 'uses the created VPC link' do
      expect(integration.connection_id).to(eq(output_vpc_link_id))
    end

    it 'uses TLS to communicate with the target' do
      expect(integration.tls_config).not_to(be_nil)
    end

    it 'uses the provided server name for certificate verification' do
      expect(integration.tls_config.server_name_to_verify)
        .to(eq(tls_server_name_to_verify))
    end

    it 'includes no request parameter mappings' do
      expect(integration.request_parameters).to(be_nil)
    end
  end

  describe 'when use_tls is false' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          use_tls: false
        )
      end
    end

    after(:context) do
      destroy(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          use_tls: false
        )
      end
    end

    it 'does not use TLS to communicate with the target' do
      expect(integration.tls_config).to(be_nil)
    end
  end

  describe 'when use_tls is true' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          use_tls: true,
          tls_server_name_to_verify:
        )
      end
    end

    after(:context) do
      destroy(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          use_tls: true,
          tls_server_name_to_verify:
        )
      end
    end

    it 'uses TLS to communicate with the target' do
      expect(integration.tls_config).not_to(be_nil)
    end

    it 'uses the provided server name for certificate verification' do
      expect(integration.tls_config.server_name_to_verify)
        .to(eq(tls_server_name_to_verify))
    end
  end

  describe 'when request_parameters are supplied' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify:,
          request_parameters: [
            {
              parameter: 'path',
              type: 'overwrite',
              value: '/some/path'
            },
            {
              parameter: 'header.x-something',
              type: 'append',
              value: 'some-value'
            }
          ]
        )
      end
    end

    after(:context) do
      destroy(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify:,
          request_parameters: [
            {
              parameter: 'path',
              type: 'overwrite',
              value: '/some/path'
            },
            {
              parameter: 'header.x-something',
              type: 'append',
              value: 'some-value'
            }
          ]
        )
      end
    end

    it 'creates a request parameter mapping for each of the supplied ' \
       'request parameters' do
      expect(integration.request_parameters)
        .to(eq(
              {
                'overwrite:path' => '/some/path',
                'append:header.x-something' => 'some-value'
              }
            ))
    end
  end
end
