# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "items" do
    it "preserves items in arrays" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "array",
        "items" => {
          "type" => "string",
          "format" => "date-time",
          "example" => "2017-01-01T12:34:56Z"
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "array",
        "items" => {
          "type" => "string",
          "format" => "date-time",
          "example" => "2017-01-01T12:34:56Z"
        }
      }

      expect(result).to eq(expected)
    end
  end
end
