require 'swagger_helper'

RSpec.describe 'Frames API', type: :request do
  path '/frames' do
    post 'Creates a frame' do
      tags 'Frames'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :frame_params, in: :body, schema: {
        type: :object,
        properties: {
          frame: {
            type: :object,
            properties: {
              x: { type: :number, example: 50.0, description: 'X coordinate of the frame center' },
              y: { type: :number, example: 50.0, description: 'Y coordinate of the frame center' },
              width: { type: :number, example: 100.0, description: 'Width of the frame', minimum: 0.1 },
              height: { type: :number, example: 80.0, description: 'Height of the frame', minimum: 0.1 },
              circles_attributes: {
                type: :array,
                description: 'Array of circles to create within the frame',
                items: {
                  type: :object,
                  properties: {
                    x: { type: :number, example: 25.0, description: 'X coordinate of the circle center' },
                    y: { type: :number, example: 25.0, description: 'Y coordinate of the circle center' },
                    diameter: { type: :number, example: 10.0, description: 'Diameter of the circle', minimum: 0.1 }
                  },
                  required: %w[x y diameter]
                }
              }
            },
            required: %w[x y width height]
          }
        },
        required: %w[frame]
      }

      response '201', 'Frame created successfully' do
        schema '$ref' => '#/components/schemas/Frame'

        let(:frame_params) do
          {
            frame: {
              x: 50.0,
              y: 50.0,
              width: 100.0,
              height: 80.0
            }
          }
        end

        run_test!
      end

      response '201', 'Frame created successfully with circles' do
        schema '$ref' => '#/components/schemas/Frame'

        let(:frame_params) do
          {
            frame: {
              x: 50.0,
              y: 50.0,
              width: 100.0,
              height: 80.0,
              circles_attributes: [
                { x: 30.0, y: 30.0, diameter: 10.0 },
                { x: 70.0, y: 30.0, diameter: 8.0 },
                { x: 50.0, y: 60.0, diameter: 12.0 }
              ]
            }
          }
        end

        run_test!
      end

      response '422', 'Invalid frame parameters' do
        schema '$ref' => '#/components/schemas/ValidationErrors'

        let(:frame_params) do
          {
            frame: {
              x: 'invalid',
              y: 'invalid',
              width: -10,
              height: -5
            }
          }
        end

        run_test!
      end

      response '422', 'Missing required parameters' do
        schema '$ref' => '#/components/schemas/ValidationErrors'

        let(:frame_params) { {} }

        run_test!
      end

      response '422', 'Frame overlaps with existing frame' do
        schema '$ref' => '#/components/schemas/ValidationErrors'

        let!(:existing_frame) { Frame.create!(x: 50, y: 50, width: 100, height: 100) }
        let(:frame_params) do
          {
            frame: {
              x: 60.0,  # Overlaps with existing frame
              y: 60.0,
              width: 100.0,
              height: 100.0
            }
          }
        end

        run_test!
      end

      response '422', 'Invalid circles within frame' do
        schema '$ref' => '#/components/schemas/ValidationErrors'

        let(:frame_params) do
          {
            frame: {
              x: 50.0,
              y: 50.0,
              width: 100.0,
              height: 80.0,
              circles_attributes: [
                { x: 150.0, y: 150.0, diameter: 10.0 } # Outside frame boundaries
              ]
            }
          }
        end

        run_test!
      end
    end
  end
end
