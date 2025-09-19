require 'rails_helper'

RSpec.describe Frame, type: :model do
  describe 'associations' do
    it { should have_many(:circles) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:x) }
    it { should validate_numericality_of(:y) }
    it { should validate_numericality_of(:width).is_greater_than(0) }
    it { should validate_numericality_of(:height).is_greater_than(0) }
  end

  describe 'overlap validation' do
    let!(:existing_frame) { Frame.create!(x: 10, y: 10, width: 4, height: 4) } # bounds: 8-12, 8-12

    context 'when frames do not overlap' do
      it 'allows frame creation' do
        frame = Frame.new(x: 20, y: 20, width: 4, height: 4) # bounds: 18-22, 18-22
        expect(frame).to be_valid
      end

      it 'allows frame creation when frames are adjacent' do
        frame = Frame.new(x: 14, y: 10, width: 4, height: 4) # bounds: 12-16, 8-12 (touching but not overlapping)
        expect(frame).to be_valid
      end
    end

    context 'when frames overlap' do
      it 'prevents frame creation' do
        frame = Frame.new(x: 12, y: 12, width: 4, height: 4) # bounds: 10-14, 10-14 (overlaps with existing)
        expect(frame).not_to be_valid
        expect(frame.errors[:base]).to include("Frame overlaps with existing frame(s)")
      end
    end

    context 'when updating existing frames' do
      it 'allows updates that do not create overlaps' do
        existing_frame.x = 30

        expect(existing_frame).to be_valid
      end

      it 'prevents updates that would create overlaps' do
        Frame.create!(x: 30, y: 30, width: 4, height: 4) # bounds: 28-32, 28-32

        existing_frame.x = 32 # bound: 30-34
        existing_frame.y = 32 # bound: 30-34

        expect(existing_frame).not_to be_valid
        expect(existing_frame.errors[:base]).to include("Frame overlaps with existing frame(s)")
      end
    end

    context 'when required attributes are missing' do
      it 'skips overlap validation when x is nil' do
        frame = Frame.new(x: nil, y: 10, width: 4, height: 4)
        frame.valid?

        expect(frame.errors[:base]).not_to include("Frame overlaps with existing frame(s)")
      end
    end
  end

  describe '#destroy' do
    subject { described_class.create!(x: 50, y: 50, width: 100, height: 100) }

    context 'when the frame is empty' do
      before { subject.destroyable? }

      it { is_expected.to be_destroyable }

      it 'destroy the model' do
        expect { subject.destroy }.to change(Frame, :count).by(-1)
      end

      it "don't have errors" do
        expect(subject.errors[:base]).to be_empty
      end
    end

    context 'when the frame has circles' do
      before do
        subject.circles.create!(x: 60, y: 60, diameter: 10)
        subject.destroyable?
      end

      it { is_expected.not_to be_destroyable }

      it "Doesn't destroy the model" do
        expect { subject.destroy }.not_to change(Frame, :count)
      end

      it 'has errors' do
        expect(subject.errors[:base]).to include("Can't destroy a frame with circles")
      end
    end
  end
end
