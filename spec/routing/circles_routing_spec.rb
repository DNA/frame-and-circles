require "rails_helper"

RSpec.describe CirclesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/circles").to route_to("circles#index")
    end

    it "routes to #create" do
      expect(post: "/frames/1/circles").to route_to("circles#create", frame_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "circles/2").to route_to("circles#update", id: "2")
    end

    it "routes to #destroy" do
      expect(delete: "/circles/2").to route_to("circles#destroy", id: "2")
    end
  end
end
