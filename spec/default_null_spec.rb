# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "default null values" do
    it "supports default values of null" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => {
          "nullableStringWithDefault" => {
            "default" => nil,
            "oneOf" => [{ "type" => "string" }, { "type" => "null" }]
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "nullableStringWithDefault" => {
            "default" => nil,
            "oneOf" => [{ "type" => "string", "nullable" => true }]
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
