require_relative 'provider'

class Project

  attr_reader :provider, :credentials

  def initialize(provider, credentials)
    @provider = provider
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

  def valid_provider?(provider)
    Provider.all;
  end

end
