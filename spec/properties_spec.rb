# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "properties" do
    it "handles type array" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => %w[string null]
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "string",
        "nullable" => true
      }

      expect(result).to eq(expected)
    end

    it "handles properties with nullable types" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "required" => ["bar"],
        "properties" => {
          "foo" => {
            "type" => "string"
          },
          "bar" => {
            "type" => %w[string null]
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "required" => ["bar"],
        "properties" => {
          "foo" => {
            "type" => "string"
          },
          "bar" => {
            "type" => "string",
            "nullable" => true
          }
        }
      }

      expect(result).to eq(expected)
    end

    it "handles additionalProperties false" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => {
          "foo" => {
            "type" => "string"
          }
        },
        "additionalProperties" => false
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "foo" => {
            "type" => "string"
          }
        },
        "additionalProperties" => false
      }

      expect(result).to eq(expected)
    end

    it "handles additionalProperties true" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => {
          "foo" => {
            "type" => "string"
          }
        },
        "additionalProperties" => true
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "foo" => {
            "type" => "string"
          }
        },
        "additionalProperties" => true
      }

      expect(result).to eq(expected)
    end

    it "handles additionalProperties as object" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => {
          "foo" => {
            "type" => "string"
          }
        },
        "additionalProperties" => {
          "type" => "object",
          "properties" => {
            "foo" => {
              "type" => "string",
              "format" => "date-time"
            }
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "foo" => {
            "type" => "string"
          }
        },
        "additionalProperties" => {
          "type" => "object",
          "properties" => {
            "foo" => {
              "type" => "string",
              "format" => "date-time"
            }
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
