# frozen_string_literal: true

require_relative "lib/open_api_json_schema_converter/version"

Gem::Specification.new do |spec|
  spec.name = "open_api_json_schema_converter"
  spec.version = OpenApiJsonSchemaConverter::VERSION
  spec.authors = ["Dmitry Ishkov"]
  spec.email = ["dmitry@hey.com"]

  spec.summary = "OpenAPI v3.0 schema to JSON Schema converter"
  spec.description = "This project was written to help convert structured outputs required for OpenAI to Gemini format."
  spec.homepage = "https://github.com/therusskiy/open_api_json_schema_converter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/therusskiy/open_api_json_schema_converter"
  spec.metadata["changelog_uri"] = "https://github.com/therusskiy/open_api_json_schema_converter/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
