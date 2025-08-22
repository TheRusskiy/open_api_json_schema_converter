# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "type array splitting" do
    it "splits type arrays correctly" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => {
          "emptyArray" => {
            "type" => []
          },
          "arrayWithNull" => {
            "type" => ["null"]
          },
          "arrayWithSingleType" => {
            "type" => ["string"]
          },
          "arrayWithNullAndSingleType" => {
            "type" => %w[null string]
          },
          "arrayWithNullAndMultipleTypes" => {
            "type" => %w[null string number]
          },
          "arrayWithMultipleTypes" => {
            "type" => %w[string number]
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "emptyArray" => {},
          "arrayWithNull" => {
            "nullable" => true
          },
          "arrayWithSingleType" => {
            "type" => "string"
          },
          "arrayWithNullAndSingleType" => {
            "nullable" => true,
            "type" => "string"
          },
          "arrayWithNullAndMultipleTypes" => {
            "nullable" => true,
            "anyOf" => [{ "type" => "string" }, { "type" => "number" }]
          },
          "arrayWithMultipleTypes" => {
            "anyOf" => [{ "type" => "string" }, { "type" => "number" }]
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
