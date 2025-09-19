require 'rails_helper'

RSpec.describe "/frames", type: :request do
  let(:valid_frame) {
    Frame.create! x: 0, y: 0, width: 100, height: 100
  }

  describe "GET /show" do
    it "renders a successful response" do
      get frame_url(valid_frame), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:frame_values) {
        { frame: { x: 10, y: 10, width: 10, height: 10 } }
      }

      it "creates a new Frame" do
        expect {
          post frames_url, params: frame_values, as: :json
        }.to change(Frame, :count).by(1)
      end

      it "renders a JSON response with the new frame" do
        post frames_url, params: frame_values, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Frame" do
        expect { post frames_url, params: {}, as: :json }.to change(Frame, :count).by(0)
      end

      it "renders a JSON response with errors for the new frame" do
        post frames_url, params: {}, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with circles" do
      let(:frame_with_circles) do
        {
          frame: {
            x: 0,
            y: 0,
            width: 100,
            height: 100,
            circles_attributes: [
              { x: 10, y: 10, diameter: 10 },
              { x: 20, y: 20, diameter: 10 },
              { x: 30, y: 30, diameter: 10 }
            ]
          }
        }
      end

      it "creates a new Frame with circles" do
        expect {
          post frames_url, params: frame_with_circles, as: :json
        }.to change(Frame, :count).by(1).and change(Circle, :count).by(3)
      end

      it "Returns a HTTP Created response" do
        post frames_url, params: frame_with_circles, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys an empty frame" do
      delete frame_url(valid_frame.id), as: :json

      expect(response).to have_http_status(:no_content)
      expect { Frame.find(valid_frame.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "return error if frame is not empty" do
      valid_frame.circles.create!(x: 0, y: 0, diameter: 10)

      delete frame_url(valid_frame.id), as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "return 404 if it doesn't exist" do
      expect { delete frame_url(0), as: :json }.not_to change(Frame, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
