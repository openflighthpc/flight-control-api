class ProviderNotFoundError < StandardError
  def initialize(invalid_provider_id)
    super("Provider \"#{invalid_provider_id}\" not found")
  end
end

class MissingCredentialsError < StandardError
  def initialize(missing_credentials)
    super("The following required credentials are missing: #{missing_credentials.join(', ')}")
  end
end