# # frozen_string_literal: true
#
# require 'spec_helper'
#
# describe 'route' do
#   let(:output_route_id) do
#     output_for(:harness, 'route_id')
#   end
#
#   let(:route) do
#     api_gateway_v2_client.get_route(
#       api_id: output_for(:prerequisites, 'api_id'),
#       route_id: output_for(:harness, 'route_id')
#     )
#   end
#
#   before(:context) do
#     provision do |vars|
#       vars.merge(
#         include_vpc_link: false,
#         vpc_link_id: output_for(:prerequisites, 'vpc_link_id')
#       )
#     end
#   end
#
#   after(:context) do
#     destroy do |vars|
#       vars.merge(
#         include_vpc_link: false,
#         vpc_link_id: output_for(:prerequisites, 'vpc_link_id')
#       )
#     end
#   end
#
#   describe 'by default' do
#     it 'creates a route for the integration' do
#       expect(route).not_to(be_nil)
#     end
#   end
# end
