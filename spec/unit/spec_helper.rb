# frozen_string_literal: true

require 'bundler/setup'

require 'ruby_terraform'
require 'rspec'
require 'rspec/terraform'

require 'support/shared_contexts/awspec'

require_relative '../../lib/paths'

Dir[File.join(__dir__, 'support', '**', '*.rb')]
  .each { |f| require f }

RubyTerraform.configure do |c|
  logger = Logger.new($stdout)
  logger.level = Logger::Severity::DEBUG
  logger.formatter = proc do |_, _, _, msg|
    "#{msg}\n"
  end

  c.logger = logger
end

RSpec::Matchers.define_negated_matcher(
  :be_non_nil, :be_nil
)
RSpec::Matchers.define_negated_matcher(
  :a_non_nil_value, :a_nil_value
)

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.terraform_binary = Paths.from_project_root_directory(
    'vendor', 'terraform', 'bin', 'terraform'
  )
  config.terraform_configuration_provider =
    RSpec::Terraform::Configuration.chain_provider(
      providers: [
        RSpec::Terraform::Configuration.seed_provider,
        RSpec::Terraform::Configuration.confidante_provider(
          parameters: %i[
            configuration_directory
            state_file
            vars
          ],
          scope_selector: ->(o) { o.slice(:role) }
        )
      ]
    )

  config.include_context 'awspec'

  config.before(:suite) do
    apply(role: :prerequisites)
  end
  config.after(:suite) { destroy(role: :prerequisites) }
end
