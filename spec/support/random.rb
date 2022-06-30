require 'faker'

module Support
  module Random
    class << self
      def alphanumeric_string(length: 10)
        Faker::Alphanumeric.alphanumeric(number: length)
      end

      def resource_type
        alphanumeric_string(length: 10)
      end

      def resource_name
        alphanumeric_string(length: 10)
      end

      def module_name
        alphanumeric_string(length: 10)
      end

      def module_address
        "module.#{module_name}"
      end

      def provider_name
        alphanumeric_string(length: 10)
      end
    end
  end
end
