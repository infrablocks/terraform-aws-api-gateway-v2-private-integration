# frozen_string_literal: true

require 'ruby_terraform'
require 'ostruct'

require_relative '../../lib/configuration'

module TerraformModule
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def output(role, name)
      params = {
        name:,
        state: configuration.for(role).state_file,
        json: true
      }
      value = RubyTerraform.output(params)
      JSON.parse(value, symbolize_names: true)
    end

    def provision(role, overrides = nil, &)
      do_provision(configuration.for(role, overrides), &)
    end

    def destroy(role, overrides = nil, opts = {}, &)
      do_destroy(configuration.for(role, overrides), opts, &)
    end

    private

    def do_provision(configuration, &)
      with_clean_directory(configuration) do
        log_action(:provisioning, configuration)
        invoke_apply(configuration, &)
        log_done
      end
    end

    def do_destroy(configuration, opts = {}, &)
      return unless opts[:force] || !ENV['DEPLOYMENT_IDENTIFIER']

      with_clean_directory(configuration) do
        log_action(:destroying, configuration)
        invoke_destroy(configuration, &)
        log_done
      end
    end

    def resolve_vars(configuration, &block)
      if block_given?
        block.call(configuration.vars.to_h)
      else
        configuration.vars.to_h
      end
    end

    def with_clean_directory(configuration)
      FileUtils.rm_rf(configuration.configuration_directory)
      FileUtils.mkdir_p(configuration.configuration_directory)

      RubyTerraform.init(
        chdir: configuration.configuration_directory,
        from_module: File.join(FileUtils.pwd, configuration.source_directory),
        input: false
      )
      yield configuration
    end

    def invoke_apply(configuration, &)
      RubyTerraform.apply(
        chdir: configuration.configuration_directory,
        state: configuration.state_file,
        vars: resolve_vars(configuration, &),
        input: false,
        auto_approve: true
      )
    end

    def invoke_destroy(configuration, &)
      RubyTerraform.destroy(
        chdir: configuration.configuration_directory,
        state: configuration.state_file,
        vars: resolve_vars(configuration, &),
        input: false,
        auto_approve: true
      )
    end

    def log_action(action, configuration)
      puts
      puts "#{action.to_s.capitalize} with deployment identifier: " \
           "#{configuration.deployment_identifier}"
      puts
    end

    def log_done
      puts
    end
  end
end
