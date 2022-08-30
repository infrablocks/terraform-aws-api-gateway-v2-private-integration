# frozen_string_literal: true

require 'spec_helper'

describe 'integration' do
  let(:alb_listeners) do
    output(role: :prerequisites, name: 'alb_listeners')
  end

  let(:integration_uri) do
    alb_listeners[:default][:arn]
  end

  def tls_server_name_to_verify
    'example.com'
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
      end
    end

    it 'creates a single integration' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .once)
    end

    it 'uses an integration type of HTTP_PROXY' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(:integration_type, 'HTTP_PROXY'))
    end

    it 'uses an integration method of ANY' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(:integration_method, 'ANY'))
    end

    it 'uses the provided integration URI' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(:integration_uri, integration_uri))
    end

    it 'uses a connection type of VPC_LINK' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(:connection_type, 'VPC_LINK'))
    end

    # it 'uses the created VPC link' do
    #   expect(subject)
    #     .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
    #           .with_attribute_reference(:connection_id, output_vpc_link_id))
    # end

    it 'uses TLS to communicate with the target' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(:tls_config, a_non_nil_value))
    end

    it 'uses the provided server name for certificate verification' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(
                [:tls_config, 0, :server_name_to_verify],
                tls_server_name_to_verify
              ))
    end

    it 'includes no request parameter mappings' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(:request_parameters, a_nil_value))
    end
  end

  describe 'when use_tls is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.use_tls = false
      end
    end

    it 'does not use TLS to communicate with the target' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration',
                                      name: 'integration')
              .with_attribute_value(:tls_config, a_nil_value))
    end
  end

  describe 'when use_tls is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = tls_server_name_to_verify
      end
    end

    it 'uses TLS to communicate with the target' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration',
                                      name: 'integration')
              .with_attribute_value(:tls_config, a_non_nil_value))
    end

    it 'uses the provided server name for certificate verification' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration',
                                      name: 'integration')
              .with_attribute_value(
                [:tls_config, 0, :server_name_to_verify],
                tls_server_name_to_verify
              ))
    end
  end

  describe 'when request_parameters are supplied' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = tls_server_name_to_verify
        vars.request_parameters = [
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
      end
    end

    it 'creates a request parameter mapping for each of the supplied ' \
       'request parameters' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_integration')
              .with_attribute_value(
                :request_parameters,
                {
                  'overwrite:path' => '/some/path',
                  'append:header.x-something' => 'some-value'
                }
              ))
    end
  end
end
