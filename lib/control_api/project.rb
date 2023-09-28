require_relative 'provider'

class Project

  attr_reader :provider_id, :credentials

  def initialize(provider_id, credentials)
    @provider_id = provider_id
    @credentials = credentials
    raise "Invalid provider id \"#{provider_id}\" given" unless provider_exists?
    raise "Missing credential fields" unless valid_credential_fields?
  end

  def verify_credential
    # TODO credential verification implementation
    # return a boolean indicating if the is 
  end

  def list_instances
    type.list_instances(credentials: @credentials)
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
  
  # This method is used to verify if the given credentials contains
  # enough fields that required by the provider.
  #
  # @return [boolean] The validation result.
  #
  def valid_credential_fields?
    credential_fields = @credentials.each_key
    Provider[@provider].required_credentials.each do |required_credential|
      return false unless credentials_fields.include?(required_credential)
    end
  end
end
