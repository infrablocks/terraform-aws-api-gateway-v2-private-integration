# frozen_string_literal: true

require 'spec_helper'

describe 'VPC link' do
  let(:subnet_ids) do
    output_for(:prerequisites, 'private_subnet_ids')
  end

  let(:output_vpc_link_id) do
    output_for(:harness, 'vpc_link_id')
  end

  let(:vpc_links) do
    api_gateway_v2_client.get_vpc_links.items
  end

  let(:vpc_link) do
    vpc_links
      .select { |link| link.subnet_ids.to_set == subnet_ids.to_set }
      .first
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

  # after(:context) do
  #   destroy do |vars|
  #     vars.merge(
  #       vpc_id: output_for(:prerequisites, 'vpc_id'),
  #       vpc_link_subnet_ids:
  #         output_for(:prerequisites, 'private_subnet_ids')
  #     )
  #   end
  # end

  describe 'by default' do
    it 'creates a VPC link in the subnets with the provided IDs' do
      expect(vpc_link).not_to(be_nil)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'uses a name including the component and deployment identifier' do
      expect(vpc_link.name).to(match(/.*#{vars.component}.*/))
      expect(vpc_link.name).to(match(/.*#{vars.deployment_identifier}.*/))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'outputs the VPC link ID' do
      expect(vpc_link.vpc_link_id).to(eq(output_vpc_link_id))
    end

    it 'includes the component and deployment identifier as tags' do
      expect(vpc_link.tags)
        .to(eq(
              {
                'Component' => vars.component,
                'DeploymentIdentifier' => vars.deployment_identifier
              }
            ))
    end
  end

  describe 'when include_vpc_link is false' do
    before(:context) do
      provision do |vars|
        vars.merge(
          include_vpc_link: false
        )
      end
    end

    it 'does not create a VPC link' do
      expect(vpc_link).to(be_nil)
    end
  end

  describe 'when include_vpc_link is true' do
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

    it 'creates a VPC link in the subnets with the provided IDs' do
      expect(vpc_link).not_to(be_nil)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'uses a name including the component and deployment identifier' do
      expect(vpc_link.name).to(match(/.*#{vars.component}.*/))
      expect(vpc_link.name).to(match(/.*#{vars.deployment_identifier}.*/))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'outputs the VPC link ID' do
      expect(vpc_link.vpc_link_id).to(eq(output_vpc_link_id))
    end

    it 'includes the component and deployment identifier as tags' do
      expect(vpc_link.tags)
        .to(eq(
              {
                'Component' => vars.component,
                'DeploymentIdentifier' => vars.deployment_identifier
              }
            ))
    end
  end
end
