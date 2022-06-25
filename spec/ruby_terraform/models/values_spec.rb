# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/ruby_terraform/models/values'

require_relative '../../support/random'
require_relative '../../support/build'

describe RubyTerraform::Models::Values do
  describe '.paths' do
    it 'returns the paths for an object of scalars' do
      object = {
        first: 1,
        second: '2',
        third: false
      }
      paths = described_class.paths(object)

      expect(paths).to(eq([[:first], [:second], [:third]]))
    end

    it 'returns the paths for an object of lists' do
      object = {
        first: [1, 2, 3],
        second: %w[value1 value2]
      }
      paths = described_class.paths(object)

      expect(paths)
        .to(eq([
                 [:first, 0],
                 [:first, 1],
                 [:first, 2],
                 [:second, 0],
                 [:second, 1]
               ]))
    end

    it 'returns the paths for an object of objects' do
      object = {
        first: {
          a: 1,
          b: 2
        },
        second: {
          c: 3,
          d: 4
        }
      }
      paths = described_class.paths(object)

      expect(paths)
        .to(eq([
                 %i[first a],
                 %i[first b],
                 %i[second c],
                 %i[second d]
               ]))
    end
  end
end
