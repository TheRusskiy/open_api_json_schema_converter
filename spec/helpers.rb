# frozen_string_literal: true

require "json"

module SpecHelpers
  def get_schema(file)
    path = File.join(__dir__, "schemas", file)
    JSON.parse(File.read(path))
  end
end
