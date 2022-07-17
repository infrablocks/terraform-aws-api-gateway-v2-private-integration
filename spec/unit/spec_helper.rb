# frozen_string_literal: true
require 'bundler/setup'

require 'ruby_terraform'
require 'rspec/terraform'

require 'support/shared_contexts/terraform'
require 'support/terraform_module'

Dir[File.join(__dir__, 'support', '**', '*.rb')]
  .sort
  .each { |f| require f }

RubyTerraform.configure do |c|
  logger = Logger.new($stdout)
  logger.level = Logger::Severity::DEBUG
  logger.formatter = proc do |_, _, _, msg|
    "#{msg}\n"
  end

  c.binary = Paths.from_project_root_directory(
    'vendor', 'terraform', 'bin', 'terraform'
  )
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
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context 'terraform'

  # config.before(:suite) do
  #   TerraformModule.provision(:prerequisites)
  # end
  # config.after(:suite) do
  #   TerraformModule.destroy(:prerequisites)
  # end
end
