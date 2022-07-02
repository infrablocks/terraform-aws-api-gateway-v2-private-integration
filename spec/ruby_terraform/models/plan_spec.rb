# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/random'
require_relative '../../support/build'

describe RubyTerraform::Models::Plan do
  describe '#format_version' do
    it 'returns the format version' do
      format_version = '1.0'
      plan = described_class.new(
        Support::Build.plan_content({ format_version: })
      )

      expect(plan.format_version).to(eq(format_version))
    end
  end

  describe '#terraform_version' do
    it 'returns the Terraform version' do
      terraform_version = '1.1.9'
      plan = described_class.new(
        Support::Build.plan_content({ terraform_version: })
      )

      expect(plan.terraform_version).to(eq(terraform_version))
    end
  end

  describe '#variables' do
    it 'return the variables' do
      variables = {
        var1: Support::Build.variable_content(value: 'val1'),
        var2: Support::Build.variable_content(value: 'val1')
      }
      plan = described_class.new(
        Support::Build.plan_content({ variables: })
      )

      expect(plan.variables).to(eq(variables))
    end
  end

  describe '#variable_values' do
    it 'return a map of variable values' do
      variables = {
        var1: Support::Build.variable_content(value: 'val1'),
        var2: Support::Build.variable_content(value: 'val2')
      }
      plan = described_class.new(
        Support::Build.plan_content({ variables: })
      )

      expect(plan.variable_values)
        .to(eq({
                 var1: 'val1',
                 var2: 'val2'
               }))
    end
  end

  describe '#resource_changes' do
    it 'returns a resource change model for each of the resource changes' do
      resource_change_content1 = Support::Build.resource_change_content
      resource_change_content2 = Support::Build.resource_change_content

      plan = described_class.new(
        Support::Build.plan_content(
          {
            resource_changes: [
              resource_change_content1,
              resource_change_content2
            ]
          }
        )
      )

      expect(plan.resource_changes)
        .to(eq([
                 RubyTerraform::Models::ResourceChange
                   .new(resource_change_content1),
                 RubyTerraform::Models::ResourceChange
                   .new(resource_change_content2)
               ]))
    end
  end

  describe '#resource_creations' do
    it 'returns all create resource changes' do
      resource_creation_content1 =
        Support::Build.resource_change_content(
          change: Support::Build.create_change_content
        )
      resource_creation_content2 =
        Support::Build.resource_change_content(
          change: Support::Build.create_change_content
        )
      resource_deletion_content =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_creation_content1,
            resource_deletion_content,
            resource_creation_content2,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_creations)
        .to(eq(
              [
                RubyTerraform::Models::ResourceChange.new(
                  resource_creation_content1
                ),
                RubyTerraform::Models::ResourceChange.new(
                  resource_creation_content2
                )
              ]
            ))
    end

    it 'returns an empty array when no create resource changes' do
      resource_deletion_content =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_deletion_content,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_creations).to(eq([]))
    end
  end

  describe '#resource_creations_matching' do
    describe 'for type' do
      it 'returns create resource changes with matching type' do
        resource_creation_content1 =
          Support::Build.resource_change_content(
            type: 'some_resource_type',
            change: Support::Build.create_change_content
          )
        resource_creation_content2 =
          Support::Build.resource_change_content(
            type: 'other_resource_type',
            change: Support::Build.create_change_content
          )

        plan = described_class.new(
          Support::Build.plan_content(
            resource_changes: [
              resource_creation_content1,
              resource_creation_content2
            ]
          )
        )

        resource_creations =
          plan.resource_creations_matching(type: 'some_resource_type')

        expect(resource_creations)
          .to(eq(
                [
                  RubyTerraform::Models::ResourceChange.new(
                    resource_creation_content1
                  )
                ]
              ))
      end

      it 'returns empty array if create resource changes have wrong type' do
        resource_creation_content1 =
          Support::Build.resource_change_content(
            type: 'other_resource_type1',
            change: Support::Build.create_change_content
          )
        resource_creation_content2 =
          Support::Build.resource_change_content(
            type: 'other_resource_type2',
            change: Support::Build.create_change_content
          )

        plan = described_class.new(
          Support::Build.plan_content(
            resource_changes: [
              resource_creation_content1,
              resource_creation_content2
            ]
          )
        )

        resource_creations =
          plan.resource_creations_matching(type: 'some_resource_type')

        expect(resource_creations).to(eq([]))
      end

      it 'returns an empty array when no create resource changes' do
        resource_deletion_content =
          Support::Build.resource_change_content(
            change: Support::Build.delete_change_content
          )
        resource_replacement_content =
          Support::Build.resource_change_content(
            change: Support::Build.replace_create_before_delete_change_content
          )

        plan = described_class.new(
          Support::Build.plan_content(
            resource_changes: [
              resource_deletion_content,
              resource_replacement_content
            ]
          )
        )

        resource_creations =
          plan.resource_creations_matching(type: 'some_resource_type')

        expect(resource_creations).to(eq([]))
      end
    end

    describe 'for type and name' do
      it 'returns create resource changes with matching type and name' do
        resource_creation_content1 =
          Support::Build.resource_change_content(
            type: 'some_resource_type',
            name: 'some_instance',
            change: Support::Build.create_change_content
          )
        resource_creation_content2 =
          Support::Build.resource_change_content(
            type: 'some_resource_type',
            name: 'some_instance',
            change: Support::Build.create_change_content
          )
        resource_creation_content3 =
          Support::Build.resource_change_content(
            type: 'some_resource_type',
            name: 'other_instance',
            change: Support::Build.create_change_content
          )

        plan = described_class.new(
          Support::Build.plan_content(
            resource_changes: [
              resource_creation_content1,
              resource_creation_content2,
              resource_creation_content3
            ]
          )
        )

        resource_creations =
          plan.resource_creations_matching(
            type: 'some_resource_type', name: 'some_instance'
          )

        expect(resource_creations)
          .to(eq([
                   RubyTerraform::Models::ResourceChange.new(
                     resource_creation_content1
                   ),
                   RubyTerraform::Models::ResourceChange.new(
                     resource_creation_content2
                   )
                 ]))
      end

      it 'returns empty array if create resource changes have wrong '\
         'type or name' do
        resource_creation_content1 =
          Support::Build.resource_change_content(
            type: 'other_resource_type',
            name: 'some_instance',
            change: Support::Build.create_change_content
          )
        resource_creation_content2 =
          Support::Build.resource_change_content(
            type: 'some_resource_type',
            name: 'other_instance',
            change: Support::Build.create_change_content
          )

        plan = described_class.new(
          Support::Build.plan_content(
            resource_changes: [
              resource_creation_content1,
              resource_creation_content2
            ]
          )
        )

        resource_creations =
          plan.resource_creations_matching(
            type: 'some_resource_type',
            name: 'some_resource_name'
          )

        expect(resource_creations).to(eq([]))
      end

      it 'returns an empty array when no create resource changes' do
        resource_deletion_content =
          Support::Build.resource_change_content(
            change: Support::Build.delete_change_content
          )
        resource_replacement_content =
          Support::Build.resource_change_content(
            change: Support::Build.replace_create_before_delete_change_content
          )

        plan = described_class.new(
          Support::Build.plan_content(
            resource_changes: [
              resource_deletion_content,
              resource_replacement_content
            ]
          )
        )

        resource_creations =
          plan.resource_creations_matching(
            type: 'some_resource_type',
            name: 'some_instance'
          )

        expect(resource_creations).to(eq([]))
      end
    end
  end

  describe '#resource_reads' do
    it 'returns all create resource changes' do
      resource_read_content1 =
        Support::Build.resource_change_content(
          change: Support::Build.read_change_content
        )
      resource_read_content2 =
        Support::Build.resource_change_content(
          change: Support::Build.read_change_content
        )
      resource_deletion_content =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_read_content1,
            resource_deletion_content,
            resource_read_content2,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_reads)
        .to(eq(
              [
                RubyTerraform::Models::ResourceChange.new(
                  resource_read_content1
                ),
                RubyTerraform::Models::ResourceChange.new(
                  resource_read_content2
                )
              ]
            ))
    end

    it 'returns an empty array when no read resource changes' do
      resource_deletion_content =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_deletion_content,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_reads).to(eq([]))
    end
  end

  describe '#resource_deletions' do
    it 'returns all delete resource changes' do
      resource_deletion_content1 =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_deletion_content2 =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_creation_content =
        Support::Build.resource_change_content(
          change: Support::Build.create_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_deletion_content1,
            resource_creation_content,
            resource_deletion_content2,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_deletions)
        .to(eq(
              [
                RubyTerraform::Models::ResourceChange.new(
                  resource_deletion_content1
                ),
                RubyTerraform::Models::ResourceChange.new(
                  resource_deletion_content2
                )
              ]
            ))
    end

    it 'returns an empty array when no delete resource changes' do
      resource_creation_content =
        Support::Build.resource_change_content(
          change: Support::Build.create_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_creation_content,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_deletions).to(eq([]))
    end
  end

  describe '#resource_updates' do
    it 'returns all update resource changes' do
      resource_update_content1 =
        Support::Build.resource_change_content(
          change: Support::Build.update_change_content
        )
      resource_update_content2 =
        Support::Build.resource_change_content(
          change: Support::Build.update_change_content
        )
      resource_creation_content =
        Support::Build.resource_change_content(
          change: Support::Build.create_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_update_content1,
            resource_creation_content,
            resource_update_content2,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_updates)
        .to(eq(
              [
                RubyTerraform::Models::ResourceChange.new(
                  resource_update_content1
                ),
                RubyTerraform::Models::ResourceChange.new(
                  resource_update_content2
                )
              ]
            ))
    end

    it 'returns an empty array when no update resource changes' do
      resource_deletion_content =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_deletion_content,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_updates).to(eq([]))
    end
  end

  describe '#resource_replacements' do
    it 'returns all replace resource changes' do
      resource_replacement_content1 =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )
      resource_replacement_content2 =
        Support::Build.resource_change_content(
          change: Support::Build.replace_delete_before_create_change_content
        )
      resource_update_content =
        Support::Build.resource_change_content(
          change: Support::Build.update_change_content
        )
      resource_creation_content =
        Support::Build.resource_change_content(
          change: Support::Build.create_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_replacement_content1,
            resource_creation_content,
            resource_update_content,
            resource_replacement_content2
          ]
        )
      )

      expect(plan.resource_replacements)
        .to(eq(
              [
                RubyTerraform::Models::ResourceChange.new(
                  resource_replacement_content1
                ),
                RubyTerraform::Models::ResourceChange.new(
                  resource_replacement_content2
                )
              ]
            ))
    end

    it 'returns an empty array when no update resource changes' do
      resource_deletion_content =
        Support::Build.resource_change_content(
          change: Support::Build.delete_change_content
        )
      resource_replacement_content =
        Support::Build.resource_change_content(
          change: Support::Build.replace_create_before_delete_change_content
        )

      plan = described_class.new(
        Support::Build.plan_content(
          resource_changes: [
            resource_deletion_content,
            resource_replacement_content
          ]
        )
      )

      expect(plan.resource_updates).to(eq([]))
    end
  end

  describe '#inspect' do
    it 'inspects the underlying content' do
      plan_content = Support::Build.plan_content
      plan = described_class.new(plan_content)

      expect(plan.inspect).to(eq(plan_content.inspect))
    end
  end

  describe '#to_h' do
    it 'returns the underlying content' do
      plan_content = Support::Build.plan_content
      plan = described_class.new(plan_content)

      expect(plan.to_h).to(eq(plan_content))
    end
  end
end
