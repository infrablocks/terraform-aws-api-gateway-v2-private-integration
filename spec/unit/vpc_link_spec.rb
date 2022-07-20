# frozen_string_literal: true

require 'spec_helper'

describe 'VPC link' do
  let(:component) { vars(:root).component }
  let(:deployment_identifier) { vars(:root).deployment_identifier }

  describe 'by default' do
    let(:vpc_link_subnet_ids) do
      output(:prerequisites, 'private_subnet_ids')
    end

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

    #     it 'outputs the VPC link ID' do
    #       expect(@plan)
    #         .to(include_output('vpc_link_id')
    #               .with_reference([???]))
    #     end

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
      @plan = plan(:root) do |vars|
        vars.merge(
          include_vpc_link: false,
          vpc_link_id: output(:prerequisites, 'vpc_link_id'),
          tls_server_name_to_verify: 'example.com'
        )
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
      output(:prerequisites, 'private_subnet_ids')
    end

    before(:context) do
      @plan = plan(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com'
        )
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

    #     it 'outputs the VPC link ID' do
    #       expect(@plan)
    #         .to(include_output('vpc_link_id')
    #               .with_reference([???]))
    #     end

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
      @plan = plan(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          tags: { Alpha: 'beta', Gamma: 'delta' }
        )
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
      @plan = plan(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          include_default_tags: false,
          tags: { Alpha: 'beta', Gamma: 'delta' }
        )
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
      @plan = plan(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          include_default_tags: true,
          tags: { Alpha: 'beta', Gamma: 'delta' }
        )
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
      @plan = plan(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          include_default_tags: false
        )
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
      @plan = plan(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          include_default_tags: true
        )
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
