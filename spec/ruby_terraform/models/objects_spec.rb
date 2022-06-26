# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/ruby_terraform/models/objects'

describe RubyTerraform::Models::Objects do
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

    it 'returns the paths for a nested complex object' do
      object = {
        a: {
          b: [1, 2, 3],
          c: [
            { d: 'value1', e: 'value2' },
            { d: 'value3', e: 'value4' }
          ],
          f: true
        }
      }
      paths = described_class.paths(object)

      expect(paths)
        .to(eq([
                 [:a, :b, 0],
                 [:a, :b, 1],
                 [:a, :b, 2],
                 [:a, :c, 0, :d],
                 [:a, :c, 0, :e],
                 [:a, :c, 1, :d],
                 [:a, :c, 1, :e],
                 %i[a f]
               ]))
    end
  end

  describe '.box' do
    it 'boxes standard scalar attribute values' do
      object = {
        attribute1: 'value1',
        attribute2: false,
        attribute3: 300
      }
      sensitive = {}

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(eq({
                 attribute1: RTM::Values.known_non_sensitive('value1'),
                 attribute2: RTM::Values.known_non_sensitive(false),
                 attribute3: RTM::Values.known_non_sensitive(300)
               }))
    end

    it 'boxes standard list attribute values' do
      object = {
        attribute1: %w[value1 value2 value3],
        attribute2: [true, false, true]
      }
      sensitive = {}

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(eq({
                 attribute1: [
                   RTM::Values.known_non_sensitive('value1'),
                   RTM::Values.known_non_sensitive('value2'),
                   RTM::Values.known_non_sensitive('value3')
                 ],
                 attribute2: [
                   RTM::Values.known_non_sensitive(true),
                   RTM::Values.known_non_sensitive(false),
                   RTM::Values.known_non_sensitive(true)
                 ]
               }))
    end

    it 'boxes standard map attribute values' do
      object = {
        attribute1: { key1: 'value1', key2: false, key3: 450 },
        attribute2: { key4: 'value2' }
      }
      sensitive = {}

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(eq({
                 attribute1: {
                   key1: RTM::Values.known_non_sensitive('value1'),
                   key2: RTM::Values.known_non_sensitive(false),
                   key3: RTM::Values.known_non_sensitive(450)
                 },
                 attribute2: {
                   key4: RTM::Values.known_non_sensitive('value2')
                 }
               }))
    end

    it 'boxes standard complex nested attribute values' do
      object = {
        attribute1: {
          key1: %w[value1 value2 value3],
          key2: { key4: true },
          key3: [{ key5: ['value4'] }, { key5: ['value5'] }]
        }
      }
      sensitive = {}

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(
          eq(
            {
              attribute1: {
                key1: [
                  RTM::Values.known_non_sensitive('value1'),
                  RTM::Values.known_non_sensitive('value2'),
                  RTM::Values.known_non_sensitive('value3')
                ],
                key2: { key4: RTM::Values.known_non_sensitive(true) },
                key3: [
                  { key5: [RTM::Values.known_non_sensitive('value4')] },
                  { key5: [RTM::Values.known_non_sensitive('value5')] }
                ]
              }
            }
          )
        )
    end

    it 'boxes sensitive scalar attribute values' do
      object = {
        attribute1: 'value1',
        attribute2: false,
        attribute3: 500
      }
      sensitive = {
        attribute1: true,
        attribute2: true,
        attribute3: true
      }

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(
          eq(
            {
              attribute1: RTM::Values.known_sensitive('value1'),
              attribute2: RTM::Values.known_sensitive(false),
              attribute3: RTM::Values.known_sensitive(500)
            }
          )
        )
    end

    it 'boxes sensitive list attribute values' do
      object = {
        attribute1: %w[value1 value2 value3],
        attribute2: [true, false, true]
      }
      sensitive = {
        attribute1: [true, false, true],
        attribute2: [false, false, true]
      }

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(eq({
                 attribute1: [
                   RTM::Values.known_sensitive('value1'),
                   RTM::Values.known_non_sensitive('value2'),
                   RTM::Values.known_sensitive('value3')
                 ],
                 attribute2: [
                   RTM::Values.known_non_sensitive(true),
                   RTM::Values.known_non_sensitive(false),
                   RTM::Values.known_sensitive(true)
                 ]
               }))
    end

    it 'boxes sensitive map attribute values' do
      object = {
        attribute1: { key1: 'value1', key2: false, key3: 450 },
        attribute2: { key4: 'value2' }
      }
      sensitive = {
        attribute1: { key1: true, key2: false, key3: false },
        attribute2: { key4: true }
      }

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(eq({
                 attribute1: {
                   key1: RTM::Values.known_sensitive('value1'),
                   key2: RTM::Values.known_non_sensitive(false),
                   key3: RTM::Values.known_non_sensitive(450)
                 },
                 attribute2: {
                   key4: RTM::Values.known_sensitive('value2')
                 }
               }))
    end

    it 'boxes sensitive complex nested attribute values' do
      object = {
        attribute1: {
          key1: %w[value1 value2 value3],
          key2: { key4: true },
          key3: [{ key5: ['value4'] }, { key5: ['value5'] }]
        }
      }
      sensitive = {
        attribute1: {
          key1: [false, true, false],
          key3: [{ key5: [true] }, { key5: [false] }]
        }
      }

      boxed = described_class.box(object, sensitive:)

      expect(boxed)
        .to(
          eq(
            {
              attribute1: {
                key1: [
                  RTM::Values.known_non_sensitive('value1'),
                  RTM::Values.known_sensitive('value2'),
                  RTM::Values.known_non_sensitive('value3')
                ],
                key2: { key4: RTM::Values.known_non_sensitive(true) },
                key3: [
                  { key5: [RTM::Values.known_sensitive('value4')] },
                  { key5: [RTM::Values.known_non_sensitive('value5')] }
                ]
              }
            }
          )
        )
    end
  end
end
