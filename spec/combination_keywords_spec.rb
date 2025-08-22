# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "combination keywords" do
    it "iterates allOfs and converts types" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "allOf" => [
          {
            "type" => "object",
            "required" => ["foo"],
            "properties" => {
              "foo" => {
                "type" => "integer",
                "format" => "int64"
              }
            }
          },
          {
            "allOf" => [
              {
                "type" => "number",
                "format" => "double"
              }
            ]
          }
        ]
      }

      result = described_class.convert(schema)

      expected = {
        "allOf" => [
          {
            "type" => "object",
            "required" => ["foo"],
            "properties" => {
              "foo" => {
                "type" => "integer",
                "format" => "int64"
              }
            }
          },
          {
            "allOf" => [
              {
                "type" => "number",
                "format" => "double"
              }
            ]
          }
        ]
      }

      expect(result).to eq(expected)
    end

    it "iterates anyOfs and converts types" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "anyOf" => [
          {
            "type" => "object",
            "required" => ["foo"],
            "properties" => {
              "foo" => {
                "type" => "integer",
                "format" => "int64"
              }
            }
          },
          {
            "anyOf" => [
              {
                "type" => "object",
                "properties" => {
                  "bar" => {
                    "type" => "number",
                    "format" => "double"
                  }
                }
              }
            ]
          }
        ]
      }

      result = described_class.convert(schema)

      expected = {
        "anyOf" => [
          {
            "type" => "object",
            "required" => ["foo"],
            "properties" => {
              "foo" => {
                "type" => "integer",
                "format" => "int64"
              }
            }
          },
          {
            "anyOf" => [
              {
                "type" => "object",
                "properties" => {
                  "bar" => {
                    "type" => "number",
                    "format" => "double"
                  }
                }
              }
            ]
          }
        ]
      }

      expect(result).to eq(expected)
    end

    it "iterates oneOfs and converts types" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "oneOf" => [
          {
            "type" => "object",
            "required" => ["foo"],
            "properties" => {
              "foo" => {
                "type" => %w[string null]
              }
            }
          },
          {
            "oneOf" => [
              {
                "type" => "object",
                "properties" => {
                  "bar" => {
                    "type" => "number",
                    "format" => "double"
                  }
                }
              }
            ]
          }
        ]
      }

      result = described_class.convert(schema)

      expected = {
        "oneOf" => [
          {
            "type" => "object",
            "required" => ["foo"],
            "properties" => {
              "foo" => {
                "type" => "string",
                "nullable" => true
              }
            }
          },
          {
            "oneOf" => [
              {
                "type" => "object",
                "properties" => {
                  "bar" => {
                    "type" => "number",
                    "format" => "double"
                  }
                }
              }
            ]
          }
        ]
      }

      expect(result).to eq(expected)
    end
  end
end
