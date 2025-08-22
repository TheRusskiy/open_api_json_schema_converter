# frozen_string_literal: true

require "json"
require_relative "open_api_json_schema_converter/constants"
require_relative "open_api_json_schema_converter/converter"
require_relative "open_api_json_schema_converter/version"

module OpenApiJsonSchemaConverter
  module_function

  def convert(schema)
    Converter.new.convert(schema)
  end
end
