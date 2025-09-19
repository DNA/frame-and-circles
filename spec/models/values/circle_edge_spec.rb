require 'rails_helper'

RSpec.describe Values::CircleEdge, type: :model do
  subject { described_class.new(*attributes) }

  describe 'initialization' do
    let(:attributes) { [ 10, 20, 4 ] }

    it 'stores x, y, and diameter values' do
      expect(subject.x).to eq(10)
      expect(subject.y).to eq(20)
      expect(subject.diameter).to eq(4)
    end
  end

  describe 'radius calculation' do
    context 'with correct values' do
      let(:attributes) { [ 10, 20, 4 ] }

      it 'calculates radius correctly' do
        expect(subject.radius).to eq(2.0)
      end
    end

    context 'when diameter is blank' do
      let(:attributes) { [ 10, 20, nil ] }

      it { expect(subject.radius).to be_nil }
    end
  end

  describe 'boundary calculations' do
    let(:attributes) { [ 10, 20, 4 ] }

    it 'calculates boundaries correctly' do
      expect(subject.left).to eq(8.0)
      expect(subject.right).to eq(12.0)
      expect(subject.bottom).to eq(18.0)
      expect(subject.top).to eq(22.0)
    end

    context 'with missing values' do
      context 'when X is blank' do
        let(:attributes) { [ nil, 20, 4 ] }

        it { expect(subject.left).to be_nil }
        it { expect(subject.right).to be_nil }
      end

      context 'when Y is blank' do
        let(:attributes) { [ 10, nil, 4 ] }

        it { expect(subject.bottom).to be_nil }
        it { expect(subject.top).to be_nil }
      end

      context 'when diameter is blank' do
        let(:attributes) { [ 10, 20, nil ] }

        it { expect(subject.left).to be_nil }
        it { expect(subject.right).to be_nil }
        it { expect(subject.bottom).to be_nil }
        it { expect(subject.top).to be_nil }
      end
    end
  end

  describe 'within frame boundary checking' do
    let(:frame_edge) { Values::FrameEdge.new(10, 10, 8, 8) } # center: (10,10), bounds: 6-14, 6-14

    subject { described_class.new(*attributes).within_frame?(frame_edge) }

    context 'when circle is within frame' do
      context "when it's completely inside frame" do
        let(:attributes) { [ 10, 10, 2 ] } # bounds: 9-11, 19-21

        it { is_expected.to be_truthy }
      end

      context "when it's touching frame edges" do
        let(:attributes) { [ 10, 10, 8 ] }

        it { is_expected.to be_truthy }
      end

      context 'when circle touches one edge' do
        let(:attributes) { [ 8, 10, 4 ] }

        it { is_expected.to be_truthy }
      end
    end

    context 'when circle extends beyond frame' do
      context 'when it extends beyond left edge' do
        let(:attributes) { [ 7, 10, 4 ] }

        it { is_expected.to be_falsey }
      end

      context 'when it extends beyond right edge' do
        let(:attributes) { [ 13, 10, 4 ] }

        it { is_expected.to be_falsey }
      end

      context 'when it extends beyond bottom edge' do
        let(:attributes) { [ 10, 7, 4 ] }

        it { is_expected.to be_falsey }
      end

      context 'when it extends beyond top edge' do
        let(:attributes) { [ 10, 13, 4 ] }

        it { is_expected.to be_falsey }
      end

      context 'when it completely outside frame' do
        let(:attributes) { [ 20, 20, 4 ] }

        it { is_expected.to be_falsey }
      end
    end
  end
end
