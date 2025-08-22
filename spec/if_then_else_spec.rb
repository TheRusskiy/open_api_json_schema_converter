# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "if-then-else conversion" do
    it "converts if-then-else" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "if" => { "type" => "object" },
        "then" => { "properties" => { "id" => { "type" => "string" } } },
        "else" => { "format" => "uuid" }
      }

      result = described_class.convert(schema)

      expected = {
        "oneOf" => [
          {
            "allOf" => [
              { "type" => "object" },
              { "properties" => { "id" => { "type" => "string" } } }
            ]
          },
          {
            "allOf" => [
              { "not" => { "type" => "object" } },
              { "format" => "uuid" }
            ]
          }
        ]
      }

      expect(result).to eq(expected)
    end

    it "converts if-then without else" do
      schema = {
        "$schema" => "http://json-schema.org/draft-07/schema#",
        "type" => "object",
        "properties" => {
          "type" => {
            "type" => "string",
            "enum" => %w[css js i18n json]
          },
          "locale" => {
            "type" => "string"
          }
        },
        "if" => {
          "properties" => {
            "type" => {
              "const" => "i18n"
            }
          }
        },
        "then" => {
          "required" => ["locale"]
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "type" => {
            "type" => "string",
            "enum" => %w[css js i18n json]
          },
          "locale" => {
            "type" => "string"
          }
        },
        "oneOf" => [
          {
            "allOf" => [
              {
                "properties" => {
                  "type" => {
                    "enum" => ["i18n"]
                  }
                }
              },
              {
                "required" => ["locale"]
              }
            ]
          },
          {
            "allOf" => [
              {
                "not" => {
                  "properties" => {
                    "type" => {
                      "enum" => ["i18n"]
                    }
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
