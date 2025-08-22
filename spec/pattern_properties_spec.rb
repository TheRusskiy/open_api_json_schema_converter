# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "pattern properties" do
    it "renames patternProperties to x-patternProperties" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "additionalProperties" => {
          "type" => "string"
        },
        "patternProperties" => {
          "^[a-z]*$" => {
            "type" => "string"
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "additionalProperties" => {
          "type" => "string"
        },
        "x-patternProperties" => {
          "^[a-z]*$" => {
            "type" => "string"
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
