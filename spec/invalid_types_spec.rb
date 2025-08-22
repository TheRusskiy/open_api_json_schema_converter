# frozen_string_literal: true

require "spec_helper"
require "helpers"

RSpec.describe OpenApiJsonSchemaConverter do
  include SpecHelpers

  describe "invalid types" do
    it "dateTime is invalid type" do
      schema = { "type" => "dateTime" }
      expect { described_class.convert(schema) }.to raise_error(
        OpenApiJsonSchemaConverter::InvalidTypeError,
        /is not a valid type/
      )
    end

    it "foo is invalid type" do
      schema = { "type" => "foo" }
      expect { described_class.convert(schema) }.to raise_error(
        OpenApiJsonSchemaConverter::InvalidTypeError,
        /is not a valid type/
      )
    end

    it "invalid type inside complex schema" do
      schema = get_schema("invalid/json-schema.json")
      expect { described_class.convert(schema) }.to raise_error(
        OpenApiJsonSchemaConverter::InvalidTypeError,
        /is not a valid type/
      )
    end
  end
end
