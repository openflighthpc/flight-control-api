require_relative 'provider'

class Project

  attr_reader :provider_id, :credentials, :scope

  def initialize(provider_id, credentials, scope = nil)
    @provider_id = provider_id
    @credentials = credentials
    raise "Invalid provider id \"#{provider_id}\" given" unless provider_exists?
    raise "The following required credentials are missing: #{missing_credentials.join(", ")}" unless !missing_credentials.any?
    @scope = scope
  end

  def valid_credentials?
    Provider[@provider_id].valid_credentials?(creds: @credentials)
  end

  def list_instances
    Provider[@provider_id].list_instances(creds: @credentials, scope: @scope)
  end

  def start_instance(instance_id)
    # TODO send some commands to start the instance
    # return a boolean indicating whether the instance successfully started
  end

  def stop_instance(instance_id)
    # TODO send some commands to stop the instance
    # return a boolean indicating whether the instance successfully stopped
  end

  private

  def provider_exists?
    Provider.exists?(@provider_id)
  end

  def missing_credentials
    Provider[@provider_id].required_credentials - (@credentials.keys)
  end
end
