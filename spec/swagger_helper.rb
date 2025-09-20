# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you"re using the rswag-api to serve API descriptions, you"ll need
  # to ensure that it"s configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join("openapi").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the "rswag:specs:swaggerize" rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe "...", openapi_spec: "v2/swagger.json"
  config.openapi_specs = {
    "v1/openapi.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Frames and Circles API",
        version: "v1",
        description: "API for managing geometric frames and circles. Frames are rectangular areas that can contain circles, with validation for overlaps and boundaries."
      },
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server"
        },
        {
          url: "https://{defaultHost}",
          variables: {
            defaultHost: {
              default: "www.example.com"
            }
          },
          description: "Production server"
        }
      ],
      components: {
        schemas: {
          Frame: {
            type: :object,
            properties: {
              id: { type: :integer, example: 123 },
              x: { type: :float, example: 50.0 },
              y: { type: :float, example: 50.0 },
              width: { type: :float, example: 100.0 },
              height: { type: :float, example: 80.0 },
              circle_positions: {
                type: :object,
                properties: {
                  topmost: { type: :array, items: { type: :float }, example: [ 10.1, 22.2 ] },
                  bottommost: { type: :array, items: { type: :float }, example: [ 10.1, 22.2 ] },
                  leftmost: { type: :array, items: { type: :float }, example: [ 10.1, 22.2 ] },
                  rightmost: { type: :array, items: { type: :float }, example: [ 10.1, 22.2 ] }
                }
              }
            },
            required: %w[id x y width height circle_positions]
          },
          ValidationErrors: {
            type: :object,
            description: "Validation error response",
            additionalProperties: {
              type: :array,
              items: { type: :string }
            },
            example: {
              x: [ "is not a number" ],
              width: [ "must be greater than 0" ],
              base: [ "Frame overlaps with existing frame(s)" ]
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize''.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
