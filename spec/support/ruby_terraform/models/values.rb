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

        def convert(object, sensitive: {})
          paths = paths(object)
          values = values(paths, object, sensitive)

          object(paths, values)
        end

        def paths(object, current = [], accumulator = [])
          normalised = normalise(object)
          case normalised
          when Enumerable
            normalised.inject(accumulator) do |a, e|
              paths(e[0], current + [e[1]], a)
            end
          else
            accumulator + [current]
          end
        end

        def values(paths, object = {}, sensitive = {})
          paths.map do |path|
            known(
              object.dig(*path),
              sensitive: sensitive.dig(*path))
          end
        end

        def object(paths, values)
          paths.zip(values).each_with_object({}) do |path_value, object|
            path, value = path_value
            update_in(object, path, value)
          end
        end

        def update_in(object, path, value)
          first_in_path, *rest_of_path = path

          rest_of_path.inject([first_in_path]) do |done, path_step|
            base = done[...-1].empty? ? object : object.dig(*done[...-1])
            head = done[-1]

            case path_step
            when Symbol then base[head] ||= {}
            when Numeric then base[head] ||= []
            end

            done + [path_step]
          end

          parent = path[...-1].empty? ? object : object.dig(*path[...-1])
          parent[path.last] = value
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
