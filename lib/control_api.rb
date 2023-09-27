# frozen_string_literal: true

Dir[File.join(__dir__, 'control_api', '*.rb')].each do |file|
  require_relative file
end
