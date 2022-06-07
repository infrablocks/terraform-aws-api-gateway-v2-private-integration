# frozen_string_literal: true

require 'spec_helper'

describe 'VPC link default security group' do
  let(:component) { vars(:root).component }
  let(:deployment_identifier) { vars(:root).deployment_identifier }

  let(:output_vpc_link_default_security_group_id) do
    output(:root, 'vpc_link_default_security_group_id')
  end

  let(:vpc_link_default_security_group) do
    security_group(output_vpc_link_default_security_group_id)
  end

  before(:context) do
    provision(:root) do |vars|
      vars.merge(
        vpc_id: output(:prerequisites, 'vpc_id'),
        vpc_link_subnet_ids:
          output(:prerequisites, 'private_subnet_ids'),
        tls_server_name_to_verify: 'example.com',
        routes: []
      )
    end
  end

  after(:context) do
    destroy(:root) do |vars|
      vars.merge(
        vpc_id: output(:prerequisites, 'vpc_id'),
        vpc_link_subnet_ids:
          output(:prerequisites, 'private_subnet_ids'),
        tls_server_name_to_verify: 'example.com',
        routes: []
      )
    end
  end

  describe 'by default' do
    it 'creates the default security group' do
      expect(vpc_link_default_security_group).to(exist)
    end

    it 'has a single ingress rule' do
      expect(vpc_link_default_security_group.inbound_rule_count).to(eq(1))
    end

    it 'has a single egress rule' do
      expect(vpc_link_default_security_group.outbound_rule_count).to(eq(1))
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(vpc_link_default_security_group.inbound)
        .to(be_opened(443)
              .protocol('tcp')
              .for('0.0.0.0/0'))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(vpc_link_default_security_group)
        .to(have_outbound_rule(
              ip_protocol: 'all',
              from_port: '-1',
              to_port: '-1',
              ip_range: '0.0.0.0/0'
            ))
    end

    it 'uses the component and deployment identifier as tags' do
      expect(tag_map(vpc_link_default_security_group))
        .to(eq(
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
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: false,
          vpc_link_id: output(:prerequisites, 'vpc_link_id'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'does not create the default security group' do
      expect(vpc_link_default_security_group).not_to(exist)
    end
  end

  describe 'when include_vpc_link is false and ' \
           'include_vpc_link_default_security_group is false' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: false,
          include_vpc_link_default_security_group: false,
          vpc_link_id: output(:prerequisites, 'vpc_link_id'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'does not create the default security group' do
      expect(vpc_link_default_security_group).not_to(exist)
    end
  end

  describe 'when include_vpc_link is false and ' \
           'include_vpc_link_default_security_group is true' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: false,
          include_vpc_link_default_security_group: true,
          vpc_link_id: output(:prerequisites, 'vpc_link_id'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'does not create the default security group' do
      expect(vpc_link_default_security_group).not_to(exist)
    end
  end

  describe 'when include_vpc_link is true and ' \
           'include_vpc_link_default_security_group is not provided' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'creates the default security group' do
      expect(vpc_link_default_security_group).to(exist)
    end

    it 'has a single ingress rule' do
      expect(vpc_link_default_security_group.inbound_rule_count).to(eq(1))
    end

    it 'has a single egress rule' do
      expect(vpc_link_default_security_group.outbound_rule_count).to(eq(1))
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(vpc_link_default_security_group.inbound)
        .to(be_opened(443)
              .protocol('tcp')
              .for('0.0.0.0/0'))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(vpc_link_default_security_group)
        .to(have_outbound_rule(
              ip_protocol: 'all',
              from_port: '-1',
              to_port: '-1',
              ip_range: '0.0.0.0/0'
            ))
    end

    it 'uses the component and deployment identifier as tags' do
      tags = vpc_link_default_security_group
             .tags
             .inject({}) { |acc, tag| acc.merge(tag.key => tag.value) }

      expect(tags)
        .to(eq(
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
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_security_group: false,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'does not create the default security group' do
      expect(vpc_link_default_security_group).not_to(exist)
    end
  end

  describe 'when include_vpc_link is true and ' \
           'include_vpc_link_default_security_group is true' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_security_group: true,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'creates the default security group' do
      expect(vpc_link_default_security_group).to(exist)
    end

    it 'has a single ingress rule' do
      expect(vpc_link_default_security_group.inbound_rule_count).to(eq(1))
    end

    it 'has a single egress rule' do
      expect(vpc_link_default_security_group.outbound_rule_count).to(eq(1))
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(vpc_link_default_security_group.inbound)
        .to(be_opened(443)
              .protocol('tcp')
              .for('0.0.0.0/0'))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(vpc_link_default_security_group)
        .to(have_outbound_rule(
              ip_protocol: 'all',
              from_port: '-1',
              to_port: '-1',
              ip_range: '0.0.0.0/0'
            ))
    end

    it 'uses the component and deployment identifier as tags' do
      tags = vpc_link_default_security_group
             .tags
             .inject({}) { |acc, tag| acc.merge(tag.key => tag.value) }

      expect(tags)
        .to(eq(
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
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_ingress_rule: false,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'creates the default security group' do
      expect(vpc_link_default_security_group).to(exist)
    end

    it 'has no ingress rules' do
      expect(vpc_link_default_security_group.inbound_rule_count).to(eq(0))
    end
  end

  describe 'when include_vpc_link_default_ingress_rule ' \
           'is true' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_ingress_rule: true,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'creates the default security group' do
      expect(vpc_link_default_security_group).to(exist)
    end

    it 'has a single ingress rule' do
      expect(vpc_link_default_security_group.inbound_rule_count).to(eq(1))
    end

    it 'allows ingress access on port 443 from all IP addresses' do
      expect(vpc_link_default_security_group.inbound)
        .to(be_opened(443)
              .protocol('tcp')
              .for('0.0.0.0/0'))
    end
  end

  describe 'when include_vpc_link_default_egress_rule ' \
           'is false' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_egress_rule: false,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'creates the default security group' do
      expect(vpc_link_default_security_group).to(exist)
    end

    it 'has no egress rules' do
      expect(vpc_link_default_security_group.outbound_rule_count).to(eq(0))
    end
  end

  describe 'when include_vpc_link_default_egress_rule ' \
           'is true' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_egress_rule: true,
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: []
        )
      end
    end

    it 'creates the default security group' do
      expect(vpc_link_default_security_group).to(exist)
    end

    it 'has a single egress rule' do
      expect(vpc_link_default_security_group.outbound_rule_count).to(eq(1))
    end

    it 'allows egress access on all ports to all IPs' do
      expect(vpc_link_default_security_group)
        .to(have_outbound_rule(
              ip_protocol: 'all',
              from_port: '-1',
              to_port: '-1',
              ip_range: '0.0.0.0/0'
            ))
    end
  end

  describe 'when tags are provided and include_default_tags is not provided' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: [],
          tags: { Alpha: 'beta', Gamma: 'delta' }
        )
      end
    end

    it 'includes the provided tags alongside the defaults' do
      expect(tag_map(vpc_link_default_security_group))
        .to(include(
              {
                'Component' => component,
                'DeploymentIdentifier' => deployment_identifier,
                'Alpha' => 'beta',
                'Gamma' => 'delta'
              }
            ))
    end
  end

  describe 'when tags are provided and include_default_tags is false' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: [],
          include_default_tags: false,
          tags: { Alpha: 'beta', Gamma: 'delta' }
        )
      end
    end

    it 'includes the provided tags' do
      expect(tag_map(vpc_link_default_security_group))
        .to(include(
              {
                'Alpha' => 'beta',
                'Gamma' => 'delta'
              }
            ))
    end

    it 'does not include the default tags' do
      expect(tag_map(vpc_link_default_security_group))
        .not_to(include(
                  {
                    'Component' => component,
                    'DeploymentIdentifier' => deployment_identifier
                  }
                ))
    end
  end

  describe 'when tags are provided and include_default_tags is true' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: [],
          include_default_tags: true,
          tags: { Alpha: 'beta', Gamma: 'delta' }
        )
      end
    end

    it 'includes the provided tags alongside the defaults' do
      expect(tag_map(vpc_link_default_security_group))
        .to(include(
              {
                'Component' => component,
                'DeploymentIdentifier' => deployment_identifier,
                'Alpha' => 'beta',
                'Gamma' => 'delta'
              }
            ))
    end
  end

  describe 'when include_default_tags is false' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: [],
          include_default_tags: false
        )
      end
    end

    it 'does not include default tags' do
      expect(tag_map(vpc_link_default_security_group))
        .not_to(include(
                  {
                    'Component' => component,
                    'DeploymentIdentifier' => deployment_identifier
                  }
                ))
    end
  end

  describe 'when include_default_tags is true' do
    before(:context) do
      provision(:root) do |vars|
        vars.merge(
          vpc_id: output(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output(:prerequisites, 'private_subnet_ids'),
          tls_server_name_to_verify: 'example.com',
          routes: [],
          include_default_tags: true
        )
      end
    end

    it 'includes default tags' do
      expect(tag_map(vpc_link_default_security_group))
        .to(include(
              {
                'Component' => component,
                'DeploymentIdentifier' => deployment_identifier
              }
            ))
    end
  end

  def tag_map(security_group)
    security_group
      .tags
      .inject({}) { |acc, tag| acc.merge(tag.key => tag.value) }
  end
end
