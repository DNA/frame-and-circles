require 'rails_helper'

RSpec.describe "/circles", type: :request do
  let(:frame) { Frame.create!(x: 0, y: 0, width: 100, height: 100) }

  let(:valid_circle) {
    frame.circles.create(x: 0, y: 0, diameter: 10)
  }

  describe "GET /index" do
    it "renders a successful response" do
      valid_circle

      get circles_url, as: :json

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:attributes) {
        { circle: { x: 0, y: 0, diameter: 20 } }
      }

      it "creates a new Circle" do
        expect {
          post frame_circles_url(frame.id), params: attributes, as: :json
        }.to change(Circle, :count).by(1)
      end

      it "renders a JSON response with the new circle" do
        post frame_circles_url(frame.id), params: attributes, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Circle" do
        expect { post frame_circles_url(frame.id), as: :json }.to change(Circle, :count).by(0)
      end

      it "renders a JSON response with errors for the new circle" do
        post frame_circles_url(frame.id), as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:attributes) {
        { circle: { x: 40 } }
      }

      it "updates the requested circle" do
        patch circle_url(valid_circle), params: attributes, as: :json

        valid_circle.reload
        expect(valid_circle.x).to eq(40)
      end

      it "renders a JSON response with the circle" do
        patch circle_url(valid_circle), params: attributes, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the circle" do
        patch circle_url(valid_circle), params: { circle: { diameter: 0 } }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested frame" do
      # debugger
      delete circle_url(valid_circle.id), as: :json

      expect(response).to have_http_status(:no_content)
      expect { Circle.find(valid_circle.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "return 404 if it doesn't exist" do
      expect { delete circle_url(0), as: :json }.not_to change(Circle, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
