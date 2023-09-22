class Project

  attr_reader type, credentials

  def initialize(type, credentials)
    @type = type
    @credentials = credentials
  end

  def verify_credential(credentials)
    # TODO credential verification implementation
    # return @credentials == credentials
  end

  def show_active_instances(credentials)
  # TODO fetch list of active instances
  # return instance list
  end

  def start_instance(instance_id)
    # TODO send some commands to start the instance
    # return something?
  end

  def stop_instance(instance_id)
    #TODO send some commands to stop the instance
    # return something?
  end

end