# frozen_string_literal: true

require 'spec_helper'

describe 'VPC link' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end

  describe 'by default' do
    let(:vpc_link_subnet_ids) do
      output(role: :prerequisites, name: 'private_subnet_ids')
    end

    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
      end
    end

    it 'creates a VPC link' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .once)
    end

    it 'uses the provided subnet IDs for the the VPC link' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :subnet_ids,
                containing_exactly(*vpc_link_subnet_ids)))
    end

    it 'uses a name including the component and deployment identifier' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :name,
                matching(/.*#{component}.*/)
                  .and(matching(/.*#{deployment_identifier}.*/))
              ))
    end

    it 'outputs the VPC link ID' do
      expect(@plan).to(
        include_output(name: 'vpc_link_id')
        #.with_reference([???])
      )
    end

    it 'uses the component and deployment identifier as tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :tags,
                {
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                }
              ))
    end
  end

  describe 'when include_vpc_link is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = false
        vars.vpc_link_id =
          output(role: :prerequisites, name: 'vpc_link_id')
        vars.tls_server_name_to_verify = 'example.com'
      end
    end

    it 'does not create a VPC link' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
                  .once)
    end
  end

  describe 'when include_vpc_link is true' do
    let(:vpc_link_subnet_ids) do
      output(role: :prerequisites, name: 'private_subnet_ids')
    end

    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
      end
    end

    it 'creates a VPC link' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .once)
    end

    it 'uses the provided subnet IDs for the the VPC link' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :subnet_ids,
                containing_exactly(*vpc_link_subnet_ids)
              ))
    end

    it 'outputs the VPC link ID' do
      expect(@plan)
        .to(include_output(name: 'vpc_link_id')
        #.with_reference([???])
        )
    end

    it 'uses a name including the component and deployment identifier' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :name,
                matching(/.*#{component}.*/)
                  .and(matching(/.*#{deployment_identifier}.*/))
              ))
    end

    it 'uses the component and deployment identifier as tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :tags,
                {
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                }
              ))
    end
  end

  describe 'when tags are provided and include_default_tags is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.tags = { Alpha: 'beta', Gamma: 'delta' }
      end
    end

    it 'includes the provided tags alongside the defaults' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :tags,
                {
                  Component: component,
                  DeploymentIdentifier: deployment_identifier,
                  Alpha: 'beta',
                  Gamma: 'delta'
                }
              ))
    end
  end

  describe 'when tags are provided and include_default_tags is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.include_default_tags = false
        vars.tags = { Alpha: 'beta', Gamma: 'delta' }
      end
    end

    it 'includes the provided tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :tags,
                including(
                  {
                    Alpha: 'beta',
                    Gamma: 'delta'
                  }
                )
              ))
    end

    it 'does not include the default tags' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
                  .with_attribute_value(
                    :tags,
                    including(
                      {
                        Component: component,
                        DeploymentIdentifier: deployment_identifier
                      }
                    )
                  ))
    end
  end

  describe 'when tags are provided and include_default_tags is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.include_default_tags = true
        vars.tags = { Alpha: 'beta', Gamma: 'delta' }
      end
    end

    it 'includes the provided tags alongside the defaults' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :tags,
                {
                  Component: component,
                  DeploymentIdentifier: deployment_identifier,
                  Alpha: 'beta',
                  Gamma: 'delta'
                }
              ))
    end
  end

  describe 'when include_default_tags is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.include_default_tags = false
      end
    end

    it 'does not include default tags' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
                  .with_attribute_value(
                    :tags,
                    including(
                      {
                        Component: component,
                        DeploymentIdentifier: deployment_identifier
                      }
                    )
                  ))
    end
  end

  describe 'when include_default_tags is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.include_default_tags = true
      end
    end

    it 'includes default tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_apigatewayv2_vpc_link')
              .with_attribute_value(
                :tags,
                including(
                  {
                    Component: component,
                    DeploymentIdentifier: deployment_identifier
                  }
                )
              ))
    end
  end
end
