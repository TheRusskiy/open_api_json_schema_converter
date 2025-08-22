# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "array items" do
    it "adds empty items object to arrays without items" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "array"
      }

      result = described_class.convert(schema)

      expected = {
        "type" => "array",
        "items" => {}
      }

      expect(result).to eq(expected)
    end
  end
end
