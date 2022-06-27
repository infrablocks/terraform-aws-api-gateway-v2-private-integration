# frozen_string_literal: true

require_relative './values'

module RubyTerraform
  module Models
    module Objects
      class << self
        def box(object, sensitive: {})
          paths = paths(object)
          values = values(paths, object, sensitive)

          object(paths, values, sensitive:)
        end

        def paths(object, current = [], accumulator = [])
          normalised = normalise(object)
          if normalised.is_a?(Enumerable)
            normalised.inject(accumulator) do |a, e|
              paths(e[0], current + [e[1]], a)
            end
          else
            accumulator + [current]
          end
        end

        def values(paths, object = {}, sensitive = {})
          paths.map do |path|
            resolved = try_dig(object, path)
            resolved_sensitive = try_dig(sensitive, path) == true

            Values.known(resolved, sensitive: resolved_sensitive)
          end
        end

        private

        def object(paths, values, sensitive: {})
          paths
            .zip(values)
            .each_with_object(Values.empty_map) do |path_value, object|
            path, value = path_value
            update_in(object, path, value, sensitive:)
          end
        end

        def update_in(object, path, value, sensitive: {})
          path.inject([[], path.drop(1)]) do |context, step|
            seen, remaining = context
            pointer = [seen, step, remaining]

            update_object_for_step(object, pointer, value, sensitive:)
            update_context_for_step(pointer)
          end
          object
        end

        def update_object_for_step(object, pointer, value, sensitive: {})
          seen, step, remaining = pointer

          parent = try_dig(object, seen, default: object)
          upcoming = remaining.first

          resolved_sensitive = try_dig(sensitive, seen + [step]) == true
          resolved = if remaining.empty?
                       value
                     else
                       empty_by_type(upcoming, sensitive: resolved_sensitive)
                     end

          parent[step] ||= resolved
        end

        def update_context_for_step(pointer)
          seen, step, remaining = pointer
          [seen + [step], remaining.drop(1)]
        end

        def try_dig(object, path, default: nil)
          return default if path.empty?

          result = object.dig(*path)
          result.nil? ? default : result
        rescue NoMethodError, TypeError
          default
        end

        def empty_by_type(value, sensitive: false)
          case value
          when Symbol then Values.empty_map(sensitive:)
          when Numeric then Values.empty_list(sensitive:)
          end
        end

        def normalise(object)
          case object
          when Array then object.each_with_index.to_a
          when Hash then object.invert.each_pair.to_a
          else object
          end
        end
      end
    end
  end
end
