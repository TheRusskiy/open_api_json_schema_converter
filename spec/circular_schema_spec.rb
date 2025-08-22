# frozen_string_literal: true

require "spec_helper"
require "helpers"

RSpec.describe OpenApiJsonSchemaConverter do
  include SpecHelpers

  describe "circular schemas" do
    it "preserves circular references in definitions" do
      schema = get_schema("circular/json-schema.json")
      result = described_class.convert(schema)
      expected = get_schema("circular/openapi.json")

      expect(result).to eq(expected)
    end

    it "handles simple circular reference" do
      schema = {
        "definitions" => {
          "node" => {
            "type" => "object",
            "properties" => {
              "value" => {
                "type" => "string"
              },
              "next" => {
                "$ref" => "#/definitions/node"
              }
            }
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "definitions" => {
          "node" => {
            "type" => "object",
            "properties" => {
              "value" => {
                "type" => "string"
              },
              "next" => {
                "$ref" => "#/definitions/node"
              }
            }
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
