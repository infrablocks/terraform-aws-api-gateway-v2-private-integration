# frozen_string_literal: true

require_relative './values'

module RubyTerraform
  module Models
    module Objects
      class << self
        def box(object, sensitive: {})
          paths = paths(object)
          values = values(paths, object, sensitive)

          object(paths, values)
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
            Values.known(
              object.dig(*path),
              sensitive: sensitive.dig(*path) || false
            )
          end
        end

        private

        def object(paths, values)
          paths.zip(values).each_with_object({}) do |path_value, object|
            path, value = path_value
            update_in(object, path, value)
          end
        end

        def update_in(object, path, value)
          path.inject([[], path.drop(1)]) do |context, step|
            seen, remaining = context

            update_object_for_step(object, step, seen, remaining, value)
            update_context_for_step(step, seen, remaining)
          end
          object
        end

        def update_object_for_step(object, step, seen, remaining, value)
          dig_if_needed(object, seen)[step] ||=
            remaining.empty? ? value : empty_by_type(remaining.first)
        end

        def update_context_for_step(step, seen, remaining)
          [seen + [step], remaining.drop(1)]
        end

        def dig_if_needed(object, path)
          path.empty? ? object : object.dig(*path)
        end

        def empty_by_type(value)
          case value
          when Symbol then {}
          when Numeric then []
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
