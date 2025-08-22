# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenApiJsonSchemaConverter do
  describe "nullable" do
    it "adds nullable: true for type: [string, null]" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => %w[string null]
      }

      result = described_class.convert(schema)

      expect(result).to eq({
                             "type" => "string",
                             "nullable" => true
                           })
    end

    %w[oneOf anyOf].each do |key|
      it "supports nullables inside sub-schemas #{key}" do
        schema = {
          "$schema" => "http://json-schema.org/draft-04/schema#",
          key => [{ "type" => "string" }, { "type" => "null" }]
        }

        result = described_class.convert(schema)

        expect(result).to eq({
                               key => [{ "type" => "string", "nullable" => true }]
                             })
      end
    end

    it "supports nullables inside definitions" do
      schema = {
        "$schema" => "http://json-schema.org/draft-07/schema#",
        "definitions" => {
          "Product" => {
            "type" => "object",
            "properties" => {
              "name" => {
                "type" => "string"
              },
              "price" => {
                "type" => "number"
              },
              "rating" => {
                "type" => %w[null number]
              }
            },
            "required" => %w[name price rating]
          },
          "ProductList" => {
            "type" => "object",
            "properties" => {
              "name" => {
                "type" => "string"
              },
              "version" => {
                "type" => "string"
              },
              "products" => {
                "type" => "array",
                "items" => {
                  "type" => "object",
                  "properties" => {
                    "name" => {
                      "type" => "string"
                    },
                    "price" => {
                      "type" => "number"
                    },
                    "rating" => {
                      "type" => %w[null number]
                    }
                  },
                  "required" => %w[name price rating]
                }
              }
            },
            "required" => %w[name products version]
          }
        }
      }

      result = described_class.convert(schema)

      expect(result).to eq({
                             "definitions" => {
                               "Product" => {
                                 "type" => "object",
                                 "properties" => {
                                   "name" => {
                                     "type" => "string"
                                   },
                                   "price" => {
                                     "type" => "number"
                                   },
                                   "rating" => {
                                     "type" => "number",
                                     "nullable" => true
                                   }
                                 },
                                 "required" => %w[name price rating]
                               },
                               "ProductList" => {
                                 "type" => "object",
                                 "properties" => {
                                   "name" => {
                                     "type" => "string"
                                   },
                                   "version" => {
                                     "type" => "string"
                                   },
                                   "products" => {
                                     "type" => "array",
                                     "items" => {
                                       "type" => "object",
                                       "properties" => {
                                         "name" => {
                                           "type" => "string"
                                         },
                                         "price" => {
                                           "type" => "number"
                                         },
                                         "rating" => {
                                           "type" => "number",
                                           "nullable" => true
                                         }
                                       },
                                       "required" => %w[name price rating]
                                     }
                                   }
                                 },
                                 "required" => %w[name products version]
                               }
                             }
                           })
    end

    it "does not add nullable for non null types" do
      schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "string"
      }

      result = described_class.convert(schema)

      expect(result).to eq({
                             "type" => "string"
                           })
    end

    %w[oneOf anyOf].each do |key|
      it "adds nullable for types with null in #{key}" do
        schema = {
          "$schema" => "http://json-schema.org/draft-04/schema#",
          "title" => "NullExample",
          "description" => "Null Example",
          key => [
            {
              "type" => "object",
              "properties" => {
                "foo" => {
                  "type" => "string"
                }
              }
            },
            {
              "type" => "object",
              "properties" => {
                "bar" => {
                  "type" => "number"
                }
              }
            },
            {
              "type" => "null"
            }
          ]
        }

        result = described_class.convert(schema)

        expect(result).to eq({
                               "title" => "NullExample",
                               "description" => "Null Example",
                               key => [
                                 {
                                   "type" => "object",
                                   "properties" => {
                                     "foo" => {
                                       "type" => "string"
                                     }
                                   },
                                   "nullable" => true
                                 },
                                 {
                                   "type" => "object",
                                   "properties" => {
                                     "bar" => {
                                       "type" => "number"
                                     }
                                   },
                                   "nullable" => true
                                 }
                               ]
                             })
      end
    end
  end
end
