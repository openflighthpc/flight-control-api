# frozen_string_literal: true

require_relative 'provider'

class Project
  attr_reader :provider_id, :credentials, :scope

  def initialize(provider_id, credentials, scope = nil)
    @provider_id = provider_id
    @credentials = credentials
    raise "Invalid provider id \"#{provider_id}\" given" unless provider_exists?

    @scope = scope
  end

  def required_credentials?
    missing_credentials.none?
  end

  def valid_credentials?
    unless required_credentials?
      raise "The following required credentials are missing: #{missing_credentials.join(', ')}"
    end

    Provider[@provider_id].valid_credentials?(creds: @credentials, scope: @scope)
  end

  def list_instances
    provider.list_instances(creds: @credentials, scope: @scope)
  end

  def instance_usage(instance_id)
    provider.instance_usage(instance_id, creds: @credentials, scope: @scope)
  end

  def start_instance(instance_id)
    provider.start_instance(instance_id, creds: @credentials, scope: @scope)
    # TODO: send some commands to start the instance
    # return a boolean indicating whether the instance successfully started
  end

  def stop_instance(instance_id)
    provider.stop_instance(instance_id, creds: @credentials, scope: @scope)
    # TODO: send some commands to stop the instance
    # return a boolean indicating whether the instance successfully stopped
  end

  def missing_credentials
    provider.required_credentials - @credentials.keys
  end

  def get_historic_instance_costs(*instance_ids, start_date, end_date)
    provider.get_historic_instance_costs(*instance_ids, start_date, end_date, creds: @credentials, scope: @scope)
  end

  private

  def provider
    @provider ||= Provider[@provider_id]
  end

  def provider_exists?
    Provider.exists?(@provider_id)
  end
end
