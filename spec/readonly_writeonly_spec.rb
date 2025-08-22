# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "readOnly and writeOnly" do
    it "maintains readOnly and writeOnly props" do
      schema = {
        "type" => "object",
        "properties" => {
          "prop1" => {
            "type" => "string",
            "readOnly" => true
          },
          "prop2" => {
            "type" => "string",
            "writeOnly" => true
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "prop1" => {
            "type" => "string",
            "readOnly" => true
          },
          "prop2" => {
            "type" => "string",
            "writeOnly" => true
          }
        }
      }

      expect(result).to eq(expected)
    end

    it "handles readOnly and writeOnly in deep schema" do
      schema = {
        "type" => "object",
        "required" => %w[prop1 prop2],
        "properties" => {
          "prop1" => {
            "type" => "string",
            "readOnly" => true
          },
          "prop2" => {
            "allOf" => [
              {
                "type" => "object",
                "required" => ["prop3"],
                "properties" => {
                  "prop3" => {
                    "type" => "object",
                    "readOnly" => true
                  }
                }
              },
              {
                "type" => "object",
                "properties" => {
                  "prop4" => {
                    "type" => "object",
                    "readOnly" => true
                  }
                }
              }
            ]
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "required" => %w[prop1 prop2],
        "properties" => {
          "prop1" => {
            "type" => "string",
            "readOnly" => true
          },
          "prop2" => {
            "allOf" => [
              {
                "type" => "object",
                "required" => ["prop3"],
                "properties" => {
                  "prop3" => {
                    "type" => "object",
                    "readOnly" => true
                  }
                }
              },
              {
                "type" => "object",
                "properties" => {
                  "prop4" => {
                    "type" => "object",
                    "readOnly" => true
                  }
                }
              }
            ]
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
