# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "exclusiveMinMax conversion" do
    it "converts numeric exclusiveMinimum and exclusiveMaximum to boolean" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "integer",
        "exclusiveMaximum" => 10,
        "exclusiveMinimum" => 0
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "integer",
        "maximum" => 10,
        "exclusiveMaximum" => true,
        "minimum" => 0,
        "exclusiveMinimum" => true
      }

      expect(result).to eq(expected)
    end
  end
end
