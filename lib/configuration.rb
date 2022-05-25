# frozen_string_literal: true

require 'securerandom'
require 'ostruct'
require 'confidante'

require_relative 'paths'
require_relative 'public_address'

class Configuration
  def initialize
    @random_deployment_identifier = SecureRandom.hex[0, 8].to_s
    @default_public_gpg_key_path = default_public_gpg_key_path
    @default_private_gpg_key_path = default_private_gpg_key_path
    @default_gpg_key_passphrase =
      begin
        File.read(default_gpg_passphrase_path)
      rescue StandardError
        nil
      end

    @delegate = Confidante.configuration
  end

  def deployment_identifier
    deployment_identifier_for({})
  end

  def deployment_identifier_for(overrides)
    (overrides && overrides[:deployment_identifier]) ||
      ENV.fetch('DEPLOYMENT_IDENTIFIER', @random_deployment_identifier)
  end

  def public_gpg_key_path
    public_gpg_key_path_for({})
  end

  def public_gpg_key_path_for(overrides)
    (overrides && overrides[:public_gpg_key_path]) ||
      ENV.fetch('PUBLIC_GPG_KEY_PATH', @default_public_gpg_key_path)
  end

  def private_gpg_key_path
    private_gpg_key_path_for({})
  end

  def private_gpg_key_path_for(overrides)
    (overrides && overrides[:private_gpg_key_path]) ||
      ENV.fetch('PRIVATE_GPG_KEY_PATH', @default_private_gpg_key_path)
  end

  def gpg_key_passphrase
    gpg_key_passphrase_for({})
  end

  def gpg_key_passphrase_for(overrides)
    (overrides && overrides[:gpg_key_passphrase]) ||
      ENV.fetch('GPG_KEY_PASSPHRASE', @default_gpg_key_passphrase)
  end

  def project_directory
    Paths.project_root_directory
  end

  def work_directory
    @delegate.work_directory
  end

  def region
    @delegate
      .for_scope(project_directory:)
      .region
  end

  def public_address
    PublicAddress.as_ip_address
  end

  def for(role, overrides = nil)
    @delegate
      .for_scope(default_scope(role))
      .for_overrides(overrides.to_h.merge(default_overrides(overrides)))
  end

  def method_missing(symbol, *_)
    @delegate
      .for_scope(project_directory:)
      .for_overrides(default_overrides({}))
      .send(symbol)
  end

  def respond_to_missing?
    true
  end

  private

  def default_scope(role)
    {
      role:,
      project_directory:
    }
  end

  def default_overrides(overrides)
    {
      public_address:,
      project_directory:,
      deployment_identifier: deployment_identifier_for(overrides),
      public_gpg_key_path: public_gpg_key_path_for(overrides),
      private_gpg_key_path: private_gpg_key_path_for(overrides),
      gpg_key_passphrase: gpg_key_passphrase_for(overrides)
    }
  end

  def default_gpg_passphrase_path
    "#{project_directory}/config/secrets/user/gpg.passphrase"
  end

  def default_private_gpg_key_path
    "#{project_directory}/config/secrets/user/gpg.private"
  end

  def default_public_gpg_key_path
    "#{project_directory}/config/secrets/user/gpg.public"
  end
end
