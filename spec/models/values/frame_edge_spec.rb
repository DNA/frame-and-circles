require 'rails_helper'

RSpec.describe Values::FrameEdge, type: :model do
  describe 'boundary calculations' do
    subject do
      described_class.new(10, 20, 4, 6)
    end

    it 'calculates left boundary' do
      expect(subject.left).to eq(8.0) # 10 - 4/2
    end

    it 'calculates right boundary' do
      expect(subject.right).to eq(12.0) # 10 + 4/2
    end

    it 'calculates bottom boundary' do
      expect(subject.bottom).to eq(17.0) # 20 - 6/2
    end

    it 'calculates top boundary' do
      expect(subject.top).to eq(23.0) # 20 + 6/2
    end
  end
end
