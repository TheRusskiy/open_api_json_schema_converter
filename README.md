# OpenAPI JSON Schema Converter

A Ruby gem for converting OpenAPI specifications to JSON Schema format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'open_api_json_schema_converter'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install open_api_json_schema_converter
```

## Usage

### Examples:

```ruby
require 'open_api_json_schema_converter'

json_schema = {
  'type' => 'object',
  'properties' => {
    'name' => { 'type' => 'string' },
    'email' => { 'type' => ['string', 'null'] }
  }
}

result = OpenApiJsonSchemaConverter.convert(json_schema)

# Result:
# {
#   'type' => 'object',
#   'properties' => {
#     'name' => { 'type' => 'string' },
#     'email' => { 'type' => 'string', 'nullable' => true }
#   }
# }
```

```ruby
require 'open_api_json_schema_converter'

json_schema = {
  'type' => 'object',
  'properties' => {
    'status' => {
      'const' => 'active',
      'description' => 'Account status'
    },
    'version' => {
      'const' => '1.0'
    }
  }
}

result = OpenApiJsonSchemaConverter.convert(json_schema)

# Result:
# {
#   'type' => 'object',
#   'properties' => {
#     'status' => {
#       'enum' => ['active'],
#       'description' => 'Account status'
#     },
#     'version' => {
#       'enum' => ['1.0']
#     }
#   }
# }
```

## License

MIT
