require "rails_helper"

RSpec.describe FramesController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/frames/1").to route_to("frames#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/frames").to route_to("frames#create")
    end

    it "routes to #destroy" do
      expect(delete: "/frames/1").to route_to("frames#destroy", id: "1")
    end
  end
end
