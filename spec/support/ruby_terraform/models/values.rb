# frozen_string_literal: true

require_relative './known_value'

module RubyTerraform
  module Models
    module Values
      class << self
        def known(value, sensitive: false)
          KnownValue.new(value, sensitive:)
        end

        def known_non_sensitive(value)
          known(value, sensitive: false)
        end

        def known_sensitive(value)
          known(value, sensitive: true)
        end
      end
    end
  end
end
