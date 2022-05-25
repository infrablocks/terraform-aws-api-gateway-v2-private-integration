# frozen_string_literal: true

require 'spec_helper'

describe 'VPC link default security group' do
  let(:output_vpc_link_default_security_group_id) do
    output_for(:harness, 'vpc_link_default_security_group_id')
  end

  let(:vpc_link_default_security_group) do
    security_group(output_vpc_link_default_security_group_id)
  end

  before(:context) do
    provision do |vars|
      vars.merge(
        vpc_id: output_for(:prerequisites, 'vpc_id'),
        vpc_link_subnet_ids:
          output_for(:prerequisites, 'private_subnet_ids')
      )
    end
  end

  after(:context) do
    destroy do |vars|
      vars.merge(
        vpc_id: output_for(:prerequisites, 'vpc_id'),
        vpc_link_subnet_ids:
          output_for(:prerequisites, 'private_subnet_ids')
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
      tags = vpc_link_default_security_group
             .tags
             .inject({}) { |acc, tag| acc.merge(tag.key => tag.value) }

      expect(tags)
        .to(eq(
              {
                'Component' => vars.component,
                'DeploymentIdentifier' => vars.deployment_identifier
              }
            ))
    end
  end

  describe 'when include_vpc_link is false and ' \
           'include_vpc_link_default_security_group is not provided' do
    before(:context) do
      provision do |vars|
        vars.merge(
          include_vpc_link: false
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
      provision do |vars|
        vars.merge(
          include_vpc_link: false,
          include_vpc_link_default_security_group: false
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
      provision do |vars|
        vars.merge(
          include_vpc_link: false,
          include_vpc_link_default_security_group: true
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
      provision do |vars|
        vars.merge(
          include_vpc_link: true,
          vpc_id: output_for(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output_for(:prerequisites, 'private_subnet_ids')
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
                'Component' => vars.component,
                'DeploymentIdentifier' => vars.deployment_identifier
              }
            ))
    end
  end

  describe 'when include_vpc_link is true and ' \
           'include_vpc_link_default_security_group is false' do
    before(:context) do
      provision do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_security_group: false,
          vpc_id: output_for(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output_for(:prerequisites, 'private_subnet_ids')
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
      provision do |vars|
        vars.merge(
          include_vpc_link: true,
          include_vpc_link_default_security_group: true,
          vpc_id: output_for(:prerequisites, 'vpc_id'),
          vpc_link_subnet_ids:
            output_for(:prerequisites, 'private_subnet_ids')
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
                'Component' => vars.component,
                'DeploymentIdentifier' => vars.deployment_identifier
              }
            ))
    end
  end
end
