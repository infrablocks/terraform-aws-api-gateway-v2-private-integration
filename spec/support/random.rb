require 'faker'

module Support
  module Random
    class << self
      def resource_type
        Faker::Alphanumeric.alphanumeric(number: 10)
      end

      def resource_name
        Faker::Alphanumeric.alphanumeric(number: 10)
      end

      def module_name
        Faker::Alphanumeric.alphanumeric(number: 10)
      end

      def module_address
        "module.#{module_name}"
      end

      def provider_name
        Faker::Alphanumeric.alphanumeric(number: 10)
      end
    end
  end
end
