# frozen_string_literal: true

require 'aws-sdk'
require 'awspec'

module Awspec
  module Helper
    module Finder
      def api_gateway_v2_client
        @api_gateway_v2_client ||=
          Awspec::Helper::ClientWrap.new(
            Aws::ApiGatewayV2::Client.new(CLIENT_OPTIONS)
          )
      end
    end
  end
end
