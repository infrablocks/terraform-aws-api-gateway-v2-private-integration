# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/random'
require_relative '../../support/build'

describe RubyTerraform::Models::Change do
  describe '#actions' do
    {
      'create' =>
        [Support::Build.create_change_content,
         [:create]],
      'read' =>
        [Support::Build.read_change_content,
         [:read]],
      'update' =>
        [Support::Build.update_change_content,
         [:update]],
      'replace (delete before create)' =>
        [Support::Build.replace_delete_before_create_change_content,
         %i[delete create]],
      'replace (create before delete)' =>
        [Support::Build.replace_create_before_delete_change_content,
         %i[create delete]],
      'delete' =>
        [Support::Build.delete_change_content,
         [:delete]]
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1][0]
        expected_actions = entry[1][1]

        change = described_class.new(change_content)

        expect(change.actions).to(eq(expected_actions))
      end
    end
  end

  describe '#before' do
    it 'returns the "before" object value' do
      before_value = {
        argument1: 'value1',
        argument2: 'value2'
      }
      change_content =
        Support::Build.change_content(
          before: before_value
        )
      change = described_class.new(change_content)

      expect(change.before).to(eq(before_value))
    end
  end

  describe '#before_sensitive' do
    it 'returns the "before_sensitive" object value' do
      before_sensitive_value = {
        argument1: true,
        argument2: true
      }
      change_content =
        Support::Build.change_content(
          before_sensitive: before_sensitive_value
        )
      change = described_class.new(change_content)

      expect(change.before_sensitive).to(eq(before_sensitive_value))
    end
  end

  describe '#before_object' do
    # rubocop:disable RSpec/ExampleLength
    it 'return the boxed before object value' do
      before = {
        attribute: {
          key1: %w[value1 value2 value3],
          key2: { key4: true },
          key3: [{ key5: ['value4'] }, { key5: ['value5'] }]
        }
      }
      before_sensitive = {
        attribute: {
          key1: [true, false, true],
          key2: true,
          key3: [{ key5: [true] }, { key5: [true] }]
        }
      }
      change_content =
        Support::Build.change_content(before:, before_sensitive:)
      change = described_class.new(change_content)

      expected_key1 = V.list(
        [
          V.known('value1', sensitive: true),
          V.known('value2'),
          V.known('value3', sensitive: true)
        ]
      )
      expected_key2 =
        V.map({ key4: V.known(true) }, sensitive: true)
      expected_key3 = V.list(
        [
          V.map(
            { key5: V.list([V.known('value4', sensitive: true)]) }
          ),
          V.map(
            { key5: V.list([V.known('value5', sensitive: true)]) }
          )
        ]
      )
      expected = V.map(
        {
          attribute: V.map(
            {
              key1: expected_key1,
              key2: expected_key2,
              key3: expected_key3
            }
          )
        }
      )

      expect(change.before_object).to(eq(expected))
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#after' do
    it 'returns the "after" object value' do
      after_object_value = {
        argument1: 'value1',
        argument2: 'value2'
      }
      change_content =
        Support::Build.change_content(
          after: after_object_value
        )
      change = described_class.new(change_content)

      expect(change.after).to(eq(after_object_value))
    end
  end

  describe '#after_unknown' do
    it 'returns the "after" object value' do
      after_unknown_object_value = {
        argument1: true,
        argument2: true
      }
      change_content =
        Support::Build.change_content(
          after_unknown: after_unknown_object_value
        )
      change = described_class.new(change_content)

      expect(change.after_unknown).to(eq(after_unknown_object_value))
    end
  end

  describe '#after_sensitive' do
    it 'returns the "after_sensitive" object value' do
      after_sensitive_object_value = {
        argument1: true,
        argument2: true
      }
      change_content =
        Support::Build.change_content(
          after_sensitive: after_sensitive_object_value
        )
      change = described_class.new(change_content)

      expect(change.after_sensitive).to(eq(after_sensitive_object_value))
    end
  end

  describe '#after_object' do
    # rubocop:disable RSpec/ExampleLength
    it 'returns the boxed after object value' do
      after = {
        attribute1: {
          key1: %w[value1 value2 value3],
          key2: { key4: true },
          key3: [{ key5: ['value4'] }, { key5: ['value5'] }]
        }
      }
      after_unknown = {
        attribute2: {
          key1: true,
          key2: true
        }
      }
      after_sensitive = {
        attribute1: {
          key1: [true, false, true],
          key2: true,
          key3: [{ key5: [true] }, { key5: [true] }]
        },
        attribute2: {
          key2: true
        }
      }
      change_content =
        Support::Build.change_content(
          after:, after_unknown:, after_sensitive:
        )
      change = described_class.new(change_content)

      expected_attribute1_key1 = V.list(
        [
          V.known('value1', sensitive: true),
          V.known('value2'),
          V.known('value3', sensitive: true)
        ]
      )
      expected_attribute1_key2 =
        V.map({ key4: V.known(true) }, sensitive: true)
      expected_attribute1_key3 = V.list(
        [
          V.map(
            { key5: V.list([V.known('value4', sensitive: true)]) }
          ),
          V.map(
            { key5: V.list([V.known('value5', sensitive: true)]) }
          )
        ]
      )
      expected_attribute1 = V.map(
        {
          key1: expected_attribute1_key1,
          key2: expected_attribute1_key2,
          key3: expected_attribute1_key3
        }
      )
      expected_attribute2 = V.map(
        {
          key1: V.unknown,
          key2: V.unknown(sensitive: true)
        }
      )
      expected = V.map(
        {
          attribute1: expected_attribute1,
          attribute2: expected_attribute2
        }
      )

      expect(change.after_object).to(eq(expected))
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#no_op?' do
    it 'returns true if the change represents a no-op' do
      change_content = Support::Build.no_op_change_content
      change = described_class.new(change_content)

      expect(change.no_op?).to(be(true))
    end

    {
      'create' => Support::Build.create_change_content,
      'read' => Support::Build.read_change_content,
      'update' => Support::Build.update_change_content,
      'replace (delete before create)' =>
        Support::Build.replace_delete_before_create_change_content,
      'replace (create before delete)' =>
        Support::Build.replace_create_before_delete_change_content,
      'delete' => Support::Build.delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.no_op?).to(be(false))
      end
    end
  end

  describe '#create?' do
    it 'returns true if the change represents a create' do
      change_content = Support::Build.create_change_content
      change = described_class.new(change_content)

      expect(change.create?)
        .to(be(true))
    end

    {
      'no_op' => Support::Build.no_op_change_content,
      'read' => Support::Build.read_change_content,
      'update' => Support::Build.update_change_content,
      'replace (delete before create)' =>
        Support::Build.replace_delete_before_create_change_content,
      'replace (create before delete)' =>
        Support::Build.replace_create_before_delete_change_content,
      'delete' => Support::Build.delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.create?)
          .to(be(false))
      end
    end
  end

  describe '#read?' do
    it 'returns true if the change represents a read' do
      change_content = Support::Build.read_change_content
      change = described_class.new(change_content)

      expect(change.read?).to(be(true))
    end

    {
      'no_op' => Support::Build.no_op_change_content,
      'create' => Support::Build.create_change_content,
      'update' => Support::Build.update_change_content,
      'replace (delete before create)' =>
        Support::Build.replace_delete_before_create_change_content,
      'replace (create before delete)' =>
        Support::Build.replace_create_before_delete_change_content,
      'delete' => Support::Build.delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.read?).to(be(false))
      end
    end
  end

  describe '#update?' do
    it 'returns true if the change represents an update' do
      change_content = Support::Build.update_change_content
      change = described_class.new(change_content)

      expect(change.update?).to(be(true))
    end

    {
      'no_op' => Support::Build.no_op_change_content,
      'create' => Support::Build.create_change_content,
      'read' => Support::Build.read_change_content,
      'replace (delete before create)' =>
        Support::Build.replace_delete_before_create_change_content,
      'replace (create before delete)' =>
        Support::Build.replace_create_before_delete_change_content,
      'delete' => Support::Build.delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.update?).to(be(false))
      end
    end
  end

  describe '#replace_delete_before_create?' do
    it 'returns true if the change represents a replace '\
       '(delete before create)' do
      change_content =
        Support::Build.replace_delete_before_create_change_content
      change = described_class.new(change_content)

      expect(change.replace_delete_before_create?)
        .to(be(true))
    end

    {
      'no_op' => Support::Build.no_op_change_content,
      'create' => Support::Build.create_change_content,
      'read' => Support::Build.read_change_content,
      'update' => Support::Build.update_change_content,
      'replace (create before delete)' =>
        Support::Build.replace_create_before_delete_change_content,
      'delete' => Support::Build.delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.replace_delete_before_create?)
          .to(be(false))
      end
    end
  end

  describe '#replace_create_before_delete?' do
    it 'returns true if the change represents a replace '\
       '(create before delete)' do
      change_content =
        Support::Build.replace_create_before_delete_change_content
      change = described_class.new(change_content)

      expect(change.replace_create_before_delete?)
        .to(be(true))
    end

    {
      'no_op' => Support::Build.no_op_change_content,
      'create' => Support::Build.create_change_content,
      'read' => Support::Build.read_change_content,
      'update' => Support::Build.update_change_content,
      'replace (delete before create)' =>
        Support::Build.replace_delete_before_create_change_content,
      'delete' => Support::Build.delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.replace_create_before_delete?)
          .to(be(false))
      end
    end
  end

  describe '#replace?' do
    {
      'replace (delete before create)' =>
        Support::Build.replace_delete_before_create_change_content,
      'replace (create before delete)' =>
        Support::Build.replace_create_before_delete_change_content
    }.each do |entry|
      it "returns true if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.replace?)
          .to(be(true))
      end
    end

    {
      'no_op' => Support::Build.no_op_change_content,
      'create' => Support::Build.create_change_content,
      'read' => Support::Build.read_change_content,
      'update' => Support::Build.update_change_content,
      'delete' => Support::Build.delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.replace?)
          .to(be(false))
      end
    end
  end

  describe '#delete?' do
    it 'returns true if the change represents a delete' do
      change_content = Support::Build.delete_change_content
      change = described_class.new(change_content)

      expect(change.delete?)
        .to(be(true))
    end

    {
      'no_op' => Support::Build.no_op_change_content,
      'create' => Support::Build.create_change_content,
      'read' => Support::Build.read_change_content,
      'update' => Support::Build.update_change_content,
      'replace (delete before create)' =>
        Support::Build.replace_delete_before_create_change_content,
      'replace (create before delete)' =>
        Support::Build.replace_create_before_delete_change_content
    }.each do |entry|
      it "returns false if the change represents a #{entry[0]}" do
        change_content = entry[1]
        change = described_class.new(change_content)

        expect(change.delete?)
          .to(be(false))
      end
    end
  end
end
