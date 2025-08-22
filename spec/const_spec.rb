# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "const conversion" do
    it "converts const to enum" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "string",
        "const" => "hello"
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "string",
        "enum" => ["hello"]
      }

      expect(result).to eq(expected)
    end

    it "handles falsy const" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "boolean",
        "const" => false
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "boolean",
        "enum" => [false]
      }

      expect(result).to eq(expected)
    end
  end
end
