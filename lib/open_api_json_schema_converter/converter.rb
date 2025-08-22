# frozen_string_literal: true

require_relative "constants"

module OpenApiJsonSchemaConverter
  class InvalidTypeError < StandardError; end

  class Converter
    def convert(schema)
      # Always clone to avoid modifying the input
      cloned_schema = deep_clone(schema)

      converted_schema = convert_schema(cloned_schema)

      # Convert unreferenced definitions
      if converted_schema["definitions"]
        converted_schema["definitions"].each do |def_name, definition|
          converted_schema["definitions"][def_name] = handle_definition(definition)
        end
      end

      converted_schema
    end

    private

    def handle_definition(definition)
      return definition unless definition.is_a?(Hash)

      if definition["type"]
        convert_schema(deep_clone(definition))
      elsif definition.is_a?(Array)
        # Handle array types with null
        type_arr = definition
        has_null = type_arr.include?("null")
        if has_null
          actual_types = type_arr.reject { |t| t == "null" }
          {
            "type" => actual_types.length == 1 ? actual_types.first : actual_types,
            "nullable" => true
          }
        else
          definition
        end
      else
        definition
      end
    end

    def convert_schema(schema)
      return schema unless schema
      return schema unless schema.is_a?(Hash)

      # First process the current level
      schema = strip_illegal_keywords(schema)
      schema = convert_types(schema)
      schema = rewrite_const(schema)
      schema = convert_dependencies(schema)
      schema = convert_nullable(schema)
      schema = rewrite_if_then_else(schema)
      schema = rewrite_exclusive_min_max(schema)
      schema = convert_examples(schema)

      schema = convert_pattern_properties(schema) if schema["patternProperties"].is_a?(Hash)

      # Arrays must have items property in OpenAPI
      schema["items"] = {} if schema["type"] == "array" && !schema.key?("items")

      # Recursively process nested schemas
      schema = process_nested_schemas(schema)

      # Should be called last
      convert_illegal_keywords_as_extensions(schema)
    end

    def process_nested_schemas(schema)
      return schema unless schema.is_a?(Hash)

      # Process properties
      if schema["properties"].is_a?(Hash)
        schema["properties"].each do |key, value|
          schema["properties"][key] = convert_schema(value)
        end
      end

      # Process items
      if schema["items"]
        schema["items"] = if schema["items"].is_a?(Array)
                            schema["items"].map { |item| convert_schema(item) }
                          else
                            convert_schema(schema["items"])
                          end
      end

      # Process additionalProperties
      if schema["additionalProperties"].is_a?(Hash)
        schema["additionalProperties"] = convert_schema(schema["additionalProperties"])
      end

      # Process allOf, anyOf, oneOf
      %w[allOf anyOf oneOf].each do |key|
        schema[key] = schema[key].map { |item| convert_schema(item) } if schema[key].is_a?(Array)
      end

      # Process not
      schema["not"] = convert_schema(schema["not"]) if schema["not"].is_a?(Hash)

      # Process definitions
      if schema["definitions"].is_a?(Hash)
        schema["definitions"].each do |key, value|
          schema["definitions"][key] = convert_schema(value)
        end
      end

      # Process patternProperties (before it's converted to x-patternProperties)
      if schema["patternProperties"].is_a?(Hash)
        schema["patternProperties"].each do |key, value|
          schema["patternProperties"][key] = convert_schema(value)
        end
      end

      schema
    end

    def strip_illegal_keywords(schema)
      return schema unless schema.is_a?(Hash)

      schema.delete("$schema")
      schema.delete("$id")
      schema.delete("id")

      schema
    end

    def convert_types(schema)
      return schema unless schema.is_a?(Hash)
      return schema unless schema.key?("type")

      validate_type(schema["type"])

      if schema["type"].is_a?(Array)
        schema["nullable"] = true if schema["type"].include?("null")

        types_without_null = schema["type"].reject { |t| t == "null" }

        if types_without_null.empty?
          schema.delete("type")
        elsif types_without_null.length == 1
          schema["type"] = types_without_null.first
        else
          schema.delete("type")
          schema["anyOf"] = types_without_null.map { |type| { "type" => type } }
        end
      elsif schema["type"] == "null"
        schema.delete("type")
        schema["nullable"] = true
      end

      schema
    end

    def validate_type(type)
      return if type.is_a?(Hash) && type["$ref"] # Refs are allowed
      return if type.is_a?(Hash) && type["properties"] # De-referenced circular ref

      types = type.is_a?(Array) ? type : [type]
      types.each do |t|
        next unless t
        unless OpenApiJsonSchemaConverter::VALID_TYPES.include?(t)
          raise InvalidTypeError, "Type \"#{t}\" is not a valid type"
        end
      end
    end

    def rewrite_const(schema)
      return schema unless schema.is_a?(Hash)

      if schema.key?("const")
        schema["enum"] = [schema["const"]]
        schema.delete("const")
      end

      schema
    end

    def convert_dependencies(schema)
      return schema unless schema.is_a?(Hash)

      deps = schema["dependencies"]
      return schema unless deps.is_a?(Hash)

      schema.delete("dependencies")
      schema["allOf"] ||= []

      deps.each do |key, value|
        one_of = {
          "oneOf" => [
            { "not" => { "required" => [key] } },
            { "required" => [key, *Array(value)].flatten }
          ]
        }
        schema["allOf"] << one_of
      end

      schema
    end

    def convert_nullable(schema)
      return schema unless schema.is_a?(Hash)

      %w[oneOf anyOf].each do |key|
        schemas = schema[key]
        next unless schemas.is_a?(Array)

        has_nullable = schemas.any? { |item| item.is_a?(Hash) && item["type"] == "null" }
        next unless has_nullable

        filtered = schemas.reject { |item| item.is_a?(Hash) && item["type"] == "null" }
        filtered.each do |schema_entry|
          schema_entry["nullable"] = true if schema_entry.is_a?(Hash)
        end

        schema[key] = filtered
      end

      schema
    end

    def rewrite_if_then_else(schema)
      return schema unless schema.is_a?(Hash)
      return schema unless schema["if"] && schema["then"]

      schema["oneOf"] = [
        { "allOf" => [schema["if"], schema["then"]].compact },
        { "allOf" => [{ "not" => schema["if"] }, schema["else"]].compact }
      ]

      schema.delete("if")
      schema.delete("then")
      schema.delete("else")

      schema
    end

    def rewrite_exclusive_min_max(schema)
      return schema unless schema.is_a?(Hash)

      if schema["exclusiveMaximum"].is_a?(Numeric)
        schema["maximum"] = schema["exclusiveMaximum"]
        schema["exclusiveMaximum"] = true
      end

      if schema["exclusiveMinimum"].is_a?(Numeric)
        schema["minimum"] = schema["exclusiveMinimum"]
        schema["exclusiveMinimum"] = true
      end

      schema
    end

    def convert_examples(schema)
      return schema unless schema.is_a?(Hash)

      if schema["examples"].is_a?(Array) && !schema["examples"].empty?
        schema["example"] = schema["examples"].first
        schema.delete("examples")
      end

      schema
    end

    def convert_pattern_properties(schema)
      return schema unless schema.is_a?(Hash)

      schema["x-patternProperties"] = schema["patternProperties"]
      schema.delete("patternProperties")
      schema["additionalProperties"] = true unless schema.key?("additionalProperties")

      schema
    end

    def convert_illegal_keywords_as_extensions(schema)
      return schema unless schema.is_a?(Hash)

      schema.keys.each do |keyword|
        next if keyword.start_with?(OpenApiJsonSchemaConverter::OAS_EXTENSION_PREFIX)
        next if OpenApiJsonSchemaConverter::ALLOWED_KEYWORDS.include?(keyword)

        extension_key = "#{OpenApiJsonSchemaConverter::OAS_EXTENSION_PREFIX}#{keyword}"
        schema[extension_key] = schema[keyword]
        schema.delete(keyword)
      end

      schema
    end

    def deep_clone(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(k, v), h|
          h[k] = deep_clone(v)
        end
      when Array
        obj.map { |item| deep_clone(item) }
      else
        obj
      end
    end
  end
end
