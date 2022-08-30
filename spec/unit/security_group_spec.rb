# frozen_string_literal: true

require 'spec_helper'

describe 'VPC link default security group' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'has a single ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'has a single egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:protocol, 'tcp')
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, 443)
              .with_attribute_value(:to_port, 443))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:protocol, "-1")
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, -1)
              .with_attribute_value(:to_port, -1))
    end

    it 'uses the component and deployment identifier as tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :tags,
                {
                  'Component' => component,
                  'DeploymentIdentifier' => deployment_identifier
                }
              ))
    end
  end

  describe 'when include_vpc_link is false and ' \
           'include_vpc_link_default_security_group is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = false
        vars.vpc_link_id =
          output(role: :prerequisites, name: 'vpc_link_id')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'does not create a default security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end
  end

  describe 'when include_vpc_link is false and ' \
           'include_vpc_link_default_security_group is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = false
        vars.include_vpc_link_default_security_group = false
        vars.vpc_link_id =
          output(role: :prerequisites, name: 'vpc_link_id')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'does not create a default security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end
  end

  describe 'when include_vpc_link is false and ' \
           'include_vpc_link_default_security_group is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = false
        vars.include_vpc_link_default_security_group = true
        vars.vpc_link_id =
          output(role: :prerequisites, name: 'vpc_link_id')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'does not create a default security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end
  end

  describe 'when include_vpc_link is true and ' \
           'include_vpc_link_default_security_group is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'has a single ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'has a single egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:protocol, 'tcp')
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, 443)
              .with_attribute_value(:to_port, 443))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:protocol, "-1")
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, -1)
              .with_attribute_value(:to_port, -1))
    end

    it 'uses the component and deployment identifier as tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :tags,
                {
                  'Component' => component,
                  'DeploymentIdentifier' => deployment_identifier
                }
              ))
    end
  end

  describe 'when include_vpc_link is true and ' \
           'include_vpc_link_default_security_group is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.include_vpc_link_default_security_group = false
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'does not create a default security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end
  end

  describe 'when include_vpc_link is true and ' \
           'include_vpc_link_default_security_group is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.include_vpc_link_default_security_group = true
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'has a single ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'has a single egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:protocol, 'tcp')
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, 443)
              .with_attribute_value(:to_port, 443))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:protocol, "-1")
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, -1)
              .with_attribute_value(:to_port, -1))
    end

    it 'uses the component and deployment identifier as tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :tags,
                {
                  'Component' => component,
                  'DeploymentIdentifier' => deployment_identifier
                }
              ))
    end
  end

  describe 'when include_vpc_link_default_ingress_rule ' \
           'is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.include_vpc_link_default_ingress_rule = false
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'has no ingress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'ingress'))
      # .with_attribute_reference(:security_group_id, ...)
    end
  end

  describe 'when include_vpc_link_default_ingress_rule ' \
           'is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.include_vpc_link_default_ingress_rule = true
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'has a single ingress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:protocol, 'tcp')
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, 443)
              .with_attribute_value(:to_port, 443))
    end
  end

  describe 'when include_vpc_link_default_egress_rule ' \
           'is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.include_vpc_link_default_egress_rule = false
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'has no egress rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
                  .with_attribute_value(:type, 'egress'))
      # .with_attribute_reference(:security_group_id, ...)
    end
  end

  describe 'when include_vpc_link_default_egress_rule ' \
           'is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_vpc_link = true
        vars.include_vpc_link_default_egress_rule = true
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
      end
    end

    it 'creates a default security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'has a single egress rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              # .with_attribute_reference(:security_group_id, ...)
              .once)
    end

    it 'allows egress access on all ports to all IPs' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:protocol, "-1")
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0'])
              .with_attribute_value(:from_port, -1)
              .with_attribute_value(:to_port, -1))
    end
  end

  describe 'when tags are provided and include_default_tags is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.vpc_id = output(role: :prerequisites, name: 'vpc_id')
        vars.vpc_link_subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
        vars.tls_server_name_to_verify = 'example.com'
        vars.routes = []
        vars.tags = { Alpha: 'beta', Gamma: 'delta' }
      end
    end

    it 'includes the provided tags alongside the defaults' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
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
        vars.routes = []
        vars.include_default_tags = false
        vars.tags = { Alpha: 'beta', Gamma: 'delta' }
      end
    end

    it 'includes the provided tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
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
        .not_to(include_resource_creation(type: 'aws_security_group')
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
        vars.routes = []
        vars.include_default_tags = true
        vars.tags = { Alpha: 'beta', Gamma: 'delta' }
      end
    end

    it 'includes the provided tags alongside the defaults' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
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
        vars.routes = []
        vars.include_default_tags = false
      end
    end

    it 'does not include default tags' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group')
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
        vars.routes = []
        vars.include_default_tags = true
      end
    end

    it 'includes default tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
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
