# frozen_string_literal: true

require "spec_helper"
require "helpers"

RSpec.describe OpenApiJsonSchemaConverter do
  include SpecHelpers

  describe "complex schemas" do
    %w[basic address calendar events].each do |test_name|
      it "converts #{test_name}/openapi.json" do
        schema = get_schema("#{test_name}/json-schema.json")
        result = described_class.convert(schema)

        expected = get_schema("#{test_name}/openapi.json")

        expect(result).to eq(expected)
      end

      it "does not modify original #{test_name} schema" do
        schema = get_schema("#{test_name}/json-schema.json")
        original_schema = Marshal.load(Marshal.dump(schema)) # Deep clone for comparison
        result = described_class.convert(schema)
        expected = get_schema("#{test_name}/openapi.json")

        # The original schema should not be modified
        expect(schema).to eq(original_schema)
        expect(result).to eq(expected)
      end
    end
  end
end
