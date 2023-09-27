require_relative 'provider'

class Project

  attr_reader :provider, :credentials

  def initialize(provider_id, credentials)
    raise 'invalid provider id given' unless provider_exists?(provider_id)
    @provider = provider_id
    @credentials = credentials
  end

  def verify_credential
    # TODO credential verification implementation
    # return a boolean indicating if the is 
  end

  def list_instances
    # TODO fetch list of instances and their status
    # return instance list
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

  def provider_exists?(provider_id)
    Provider.exists?[provider_id]
  end

end
