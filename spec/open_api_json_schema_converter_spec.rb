# frozen_string_literal: true

RSpec.describe OpenApiJsonSchemaConverter do
  it "has a version number" do
    expect(OpenApiJsonSchemaConverter::VERSION).not_to be nil
  end
  describe ".convert" do
    let(:schema) do
      {
        "type" => %w[string null],
        "format" => "date-time",
        "$schema" => "http://json-schema.org/draft-04/schema#"
      }
    end
    let(:expected_data) do
      {
        "type" => "string",
        "format" => "date-time",
        "nullable" => true
      }
    end
    subject { described_class.convert(schema) }

    it { is_expected.to eq expected_data }
  end
end
