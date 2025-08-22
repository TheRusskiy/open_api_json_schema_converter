# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "rewrite as extensions" do
    it "renames illegal (unknown) keywords as extensions and skips those that already are" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => {
          "subject" => {
            "type" => "string",
            "customProperty" => true,
            "x-alreadyAnExtension" => true
          }
        }
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "object",
        "properties" => {
          "subject" => {
            "type" => "string",
            "x-customProperty" => true,
            "x-alreadyAnExtension" => true
          }
        }
      }

      expect(result).to eq(expected)
    end
  end
end
