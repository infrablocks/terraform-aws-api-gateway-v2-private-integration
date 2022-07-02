# frozen_string_literal: true

require_relative 'resource_change'

module RubyTerraform
  module Models
    class Plan
      def initialize(content)
        @content = content
      end

      def format_version
        @content[:format_version]
      end

      def terraform_version
        @content[:terraform_version]
      end

      def variables
        @content[:variables]
      end

      def variable_values
        variables.transform_values { |value| value[:value] }
      end

      def resource_changes
        @content[:resource_changes].map do |resource_change|
          ResourceChange.new(resource_change)
        end
      end

      def resource_creations
        resource_changes.filter(&:create?)
      end

      def resource_creations_matching(definition)
        resource_creations.filter do |resource_creation|
          definition.all? do |method, value|
            resource_creation.send(method) == value
          end
        end
      end

      def resource_reads
        resource_changes.filter(&:read?)
      end

      def resource_deletions
        resource_changes.filter(&:delete?)
      end

      def resource_updates
        resource_changes.filter(&:update?)
      end

      def resource_replacements
        resource_changes.filter(&:replace?)
      end

      def resource_changes_with_type(type)
        resource_changes.filter do |resource_change|
          resource_change.type == type
        end
      end

      def inspect
        @content.inspect
      end

      def to_h
        @content
      end
    end
  end
end
