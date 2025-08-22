# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "examples conversion" do
    it "uses the first example from a schema" do
      schema = {
        "$schema" => "http://json-schema.org/draft-06/schema#",
        "examples" => %w[foo bar]
      }

      result = described_class.convert(schema)

      expect(result).to eq({
                             "example" => "foo"
                           })
    end
  end
end
