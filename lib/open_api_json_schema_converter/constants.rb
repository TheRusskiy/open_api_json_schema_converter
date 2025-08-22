# frozen_string_literal: true

module OpenApiJsonSchemaConverter
  ALLOWED_KEYWORDS = %w[
    $ref
    definitions
    title
    multipleOf
    maximum
    exclusiveMaximum
    minimum
    exclusiveMinimum
    maxLength
    minLength
    pattern
    maxItems
    minItems
    uniqueItems
    maxProperties
    minProperties
    required
    enum
    type
    not
    allOf
    oneOf
    anyOf
    items
    properties
    additionalProperties
    description
    format
    default
    nullable
    discriminator
    readOnly
    writeOnly
    example
    externalDocs
    deprecated
    xml
  ].freeze

  VALID_TYPES = %w[
    null
    boolean
    object
    array
    number
    string
    integer
  ].freeze

  OAS_EXTENSION_PREFIX = "x-"
end
