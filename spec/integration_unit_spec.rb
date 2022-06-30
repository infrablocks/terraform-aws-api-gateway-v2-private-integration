# frozen_string_literal: true

require 'spec_helper'

RSpec::Matchers.define :include_resource_creation do |type|
  match do |plan|
    resource_changes = plan.find_resource_changes_by_type(type)
    resource_creations = resource_changes.filter(&:create?)

    return false if @count && resource_creations.length != @count
    return false if resource_creations.empty?

    pp plan.to_h

    if @arguments
      return resource_creations.any? do |resource_creation|
        @arguments.all? do |name, value|
          resource_creation.change.after[name] == value
        end
      end
    end

    return true
  end

  chain :count do |count|
    @count = count
  end

  chain :with_argument_value do |name, value|
    @arguments = (@arguments || {}).merge(name => value)
  end

  failure_message do |plan|
    resource_creations = plan.resource_creations.map do |resource_creation|
      "#{resource_creation.type}.#{resource_creation.name}"
    end
    "\nexpected: a plan with a resource creation for type: #{type}" \
      "\n     got: a plan with resource creations:" \
      "\n            - #{resource_creations.join("\n            - ")}"
  end

  failure_message_when_negated do |plan|
    resource_creations = plan.resource_creations.map do |resource_creation|
      "#{resource_creation.type}.#{resource_creation.name}"
    end
    "\nexpected: a plan without a resource creation for type: #{type}" \
      "\n     got: a plan with resource creations:" \
      "\n            - #{resource_creations.join("\n            - ")}"
  end
end

describe 'integration' do
  let(:alb_listeners) do
    output(:prerequisites, 'alb_listeners')
  end

  let(:integration_uri) do
    alb_listeners[:default][:arn]
  end

  def tls_server_name_to_verify
    'example.com'
  end

  describe 'by default' do
    subject do
      plan(:root) do |vars|
        vars.merge(
          deployment_identifier: 'spinach',
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com'
        )
      end
    end

    fit 'creates a single integration' do
      require 'pp'
      pp subject.to_h
      # expect(subject)
      #   .to(include_resource_creation('aws_apigatewayv2_integration')
      #         .count(1))
    end

    # it 'uses an integration type of HTTP_PROXY' do
    #   expect(subject)
    #     .to(include_resource_creation('aws_apigatewayv2_integration',
    #                                   'integration')
    #           .with_argument_value(:integration_type, 'HTTP_PROXY'))
    # end
    #
    # it 'uses an integration method of ANY' do
    #   expect(subject)
    #     .to(include_resource_creation('aws_apigatewayv2_integration',
    #                                   'integration')
    #           .with_argument_value(:integration_method, 'ANY'))
    # end
    #
    # it 'uses the provided integration URI' do
    #   expect(subject)
    #     .to(include_resource_creation('aws_apigatewayv2_integration',
    #                                   'integration')
    #           .with_argument_value(:integration_uri, integration_uri))
    # end
    #
    # it 'uses a connection type of VPC_LINK' do
    #   expect(subject)
    #     .to(include_resource_creation('aws_apigatewayv2_integration',
    #                                   'integration')
    #           .with_argument_value(:connection_type, 'VPC_LINK'))
    # end

    # it 'uses the created VPC link' do
    #   expect(subject)
    #     .to(include_resource_creation('aws_apigatewayv2_integration',
    #                                   'integration')
    #           .with_argument_reference(:connection_id, output_vpc_link_id))
    # end

    # it '' do
    #   expect(integration.connection_id).to(eq())
    # end
    #
    # it 'uses TLS to communicate with the target' do
    #   expect(integration.tls_config).not_to(be_nil)
    # end
    #
    # it 'uses the provided server name for certificate verification' do
    #   expect(integration.tls_config.server_name_to_verify)
    #     .to(eq(tls_server_name_to_verify))
    # end
    #
    # it 'includes no request parameter mappings' do
    #   expect(integration.request_parameters).to(be_nil)
    # end
  end

  # describe 'when use_tls is false' do
  #   before(:context) do
  #     provision(:root) do |vars|
  #       vars.merge(
  #         vpc_id: output(:prerequisites, 'vpc_id'),
  #         vpc_link_subnet_ids:
  #           output(:prerequisites, 'private_subnet_ids'),
  #         use_tls: false
  #       )
  #     end
  #   end
  #
  #   after(:context) do
  #     destroy(:root) do |vars|
  #       vars.merge(
  #         vpc_id: output(:prerequisites, 'vpc_id'),
  #         vpc_link_subnet_ids:
  #           output(:prerequisites, 'private_subnet_ids'),
  #         use_tls: false
  #       )
  #     end
  #   end
  #
  #   it 'does not use TLS to communicate with the target' do
  #     expect(integration.tls_config).to(be_nil)
  #   end
  # end
  #
  # describe 'when use_tls is true' do
  #   before(:context) do
  #     provision(:root) do |vars|
  #       vars.merge(
  #         vpc_id: output(:prerequisites, 'vpc_id'),
  #         vpc_link_subnet_ids:
  #           output(:prerequisites, 'private_subnet_ids'),
  #         use_tls: true,
  #         tls_server_name_to_verify:
  #       )
  #     end
  #   end
  #
  #   after(:context) do
  #     destroy(:root) do |vars|
  #       vars.merge(
  #         vpc_id: output(:prerequisites, 'vpc_id'),
  #         vpc_link_subnet_ids:
  #           output(:prerequisites, 'private_subnet_ids'),
  #         use_tls: true,
  #         tls_server_name_to_verify:
  #       )
  #     end
  #   end
  #
  #   it 'uses TLS to communicate with the target' do
  #     expect(integration.tls_config).not_to(be_nil)
  #   end
  #
  #   it 'uses the provided server name for certificate verification' do
  #     expect(integration.tls_config.server_name_to_verify)
  #       .to(eq(tls_server_name_to_verify))
  #   end
  # end
  #
  # describe 'when request_parameters are supplied' do
  #   before(:context) do
  #     provision(:root) do |vars|
  #       vars.merge(
  #         vpc_id: output(:prerequisites, 'vpc_id'),
  #         vpc_link_subnet_ids:
  #           output(:prerequisites, 'private_subnet_ids'),
  #         tls_server_name_to_verify:,
  #         request_parameters: [
  #           {
  #             parameter: 'path',
  #             type: 'overwrite',
  #             value: '/some/path'
  #           },
  #           {
  #             parameter: 'header.x-something',
  #             type: 'append',
  #             value: 'some-value'
  #           }
  #         ]
  #       )
  #     end
  #   end
  #
  #   after(:context) do
  #     destroy(:root) do |vars|
  #       vars.merge(
  #         vpc_id: output(:prerequisites, 'vpc_id'),
  #         vpc_link_subnet_ids:
  #           output(:prerequisites, 'private_subnet_ids'),
  #         tls_server_name_to_verify:,
  #         request_parameters: [
  #           {
  #             parameter: 'path',
  #             type: 'overwrite',
  #             value: '/some/path'
  #           },
  #           {
  #             parameter: 'header.x-something',
  #             type: 'append',
  #             value: 'some-value'
  #           }
  #         ]
  #       )
  #     end
  #   end
  #
  #   it 'creates a request parameter mapping for each of the supplied ' \
  #      'request parameters' do
  #     expect(integration.request_parameters)
  #       .to(eq(
  #             {
  #               'overwrite:path' => '/some/path',
  #               'append:header.x-something' => 'some-value'
  #             }
  #           ))
  #   end
  # end
end
