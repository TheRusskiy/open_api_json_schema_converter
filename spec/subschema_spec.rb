# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "subschemas" do
    it "strips $id from all subschemas not just root" do
      schema = {
        "$id" => "https://foo/bla",
        "id" => "https://foo/bla",
        "$schema" => "http://json-schema.org/draft-06/schema#",
        "type" => "object",
        "properties" => {
          "foo" => {
            "$id" => "/properties/foo",
            "type" => "array",
            "items" => {
              "$id" => "/properties/foo/items",
              "type" => "object",
              "properties" => {
                "id" => {
                  "$id" => "/properties/foo/items/properties/id",
                  "type" => "string"
                }
              }
            }
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "foo" => {
            "type" => "array",
            "items" => {
              "type" => "object",
              "properties" => {
                "id" => {
                  "type" => "string"
                }
              }
            }
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
