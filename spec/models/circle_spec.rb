require 'rails_helper'

RSpec.describe Circle, type: :model do
  let(:attributes) { { x: nil, y: nil, diameter: nil } } # bounds: 6-10, 8-12
  let!(:frame) { Frame.create!(x: 10, y: 10, width: 8, height: 8) } # bounds: 6-14, 6-14

  subject do
    Circle.new(attributes).tap { _1.frame = frame }
  end

  describe 'associations' do
    it { should belong_to(:frame) }
  end

  describe 'validations' do
    it { should validate_presence_of(:frame) }
    it { should validate_numericality_of(:x) }
    it { should validate_numericality_of(:y) }
    it { should validate_numericality_of(:diameter).is_greater_than(0) }
  end

  describe 'frame boundary validation' do
    context 'when circle is completely inside frame' do
      let(:attributes) { { x: 10, y: 10, diameter: 4 } } # bounds: 6-10, 8-12

      it { is_expected.to be_valid }
    end

    context 'when circle touches the frame edges' do
      let(:attributes) { { x: 10, y: 10, diameter: 8 } } # bounds: 6-14, 6-14

      it { is_expected.to be_valid }
    end

    context 'when circle touches one edge' do
      let(:attributes) { { x: 8, y: 10, diameter: 4 } } # bounds: 6-10, 8-12

      it { is_expected.to be_valid }
    end

    context 'when circle extends beyond frame boundaries' do
      context 'when extending beyond left edge' do
        let(:attributes) { { x: 7, y: 10, diameter: 4 } } # bounds: 5-9, 8-12

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to be_empty }
      end

      context 'when extending beyond right edge' do
        let(:attributes) { { x: 13, y: 10, diameter: 4 } } # bounds: 11-15, 8-12

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to be_empty }
      end

      context 'when extending beyond bottom edge' do
        let(:attributes) { { x: 10, y: 7, diameter: 4 } } # bounds: 8-12, 5-9

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to be_empty }
      end

      context 'when extending beyond top edge' do
        let(:attributes) { { x: 10, y: 13, diameter: 4 } } # bounds: 8-12, 11-15

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to be_empty }
      end

      context 'when completely outside frame' do
        let(:attributes) { { x: 20, y: 20, diameter: 4 } } # bounds: 18-22, 18-22

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to be_empty }
      end
    end

    context 'when required attributes are missing' do
      context 'when frame is nil' do
        let(:attributes) { { x: 10, y: 10, diameter: 4 } } # bounds: 8-12, 8-12

        it { is_expected.to be_valid }
        it { expect(subject.errors[:base]).to be_empty }
      end
    end
  end

  describe 'circle overlap validation' do
    let(:frame) { Frame.create!(x: 50, y: 50, width: 20, height: 20) } # bounds: 40-60, 40-60
    let!(:existing_circle) { Circle.create!(frame: frame, x: 45, y: 45, diameter: 4) } # center: (45,45), radius: 2

    before { subject.valid? }

    context 'when circles do not overlap' do
      context 'when there is no overlap' do
        let(:attributes) { { x: 55, y: 55, diameter: 4 } } # center: (55,55), radius: 2, distance: ~14.14

        it { is_expected.to be_valid }
      end

      context 'when circles are touching exactly' do
        let(:attributes) { { x: 49, y: 45, diameter: 4 } } # center: (49,45), radius: 2, distance: 4, sum of radii: 4

        it { is_expected.to be_valid }
      end
    end

    context 'when circles overlap' do
      context 'when circles intersect' do
        let(:attributes) { { x: 47, y: 45, diameter: 4 } } # center: (47,45), radius: 2, distance: 2, sum of radii: 4

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to include("Circle overlaps with existing circle(s)") }
      end

      context 'when new circle contains existing circle' do
        let(:attributes) { { x: 45, y: 45, diameter: 10 } } # center: (45,45), radius: 5, same center, larger

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to include("Circle overlaps with existing circle(s)") }
      end

      context 'when new circle is contained within existing circle' do
        before do
          Circle.create!(frame: frame, x: 55, y: 55, diameter: 8) # center: (55,55), radius: 4, bounds: 51-59

          subject.valid?
        end

        let(:attributes) { { x: 55, y: 55, diameter: 4 } } # center: (55,55), radius: 2, same center, smaller

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to include("Circle overlaps with existing circle(s)") }
      end
    end

    context 'when updating existing circles' do
      let(:attributes) { { x: 55, y: 55, diameter: 4 } } # center: (55,55), radius: 2, distance: ~14.14

      context 'when update do not overlap' do
        before do
          subject.x = 56
          subject.valid?
        end

        it { is_expected.to be_valid }
      end

      context 'when updates would overlaps' do
        before do
          Circle.create!(frame: frame, x: 55, y: 55, diameter: 4)

          existing_circle.x = 53
          existing_circle.y = 53

          subject.valid?
        end

        it { is_expected.not_to be_valid }
        it { expect(subject.errors[:base]).to include("Circle overlaps with existing circle(s)") }
      end
    end
  end
end
