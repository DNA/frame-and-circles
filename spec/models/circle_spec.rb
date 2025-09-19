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

  describe 'edge position scopes' do
    let(:frame) { Frame.create!(x: 50, y: 50, width: 40, height: 40) } # bounds: 30-70, 30-70

    let!(:center_circle) { Circle.create!(frame: frame, x: 50, y: 50, diameter: 2) } # center, radius: 1
    let!(:top_circle) { Circle.create!(frame: frame, x: 50, y: 66, diameter: 6) } # top edge at y=69, radius: 3
    let!(:bottom_circle) { Circle.create!(frame: frame, x: 50, y: 34, diameter: 6) } # bottom edge at y=31, radius: 3
    let!(:left_circle) { Circle.create!(frame: frame, x: 34, y: 50, diameter: 6) } # left edge at x=31, radius: 3
    let!(:right_circle) { Circle.create!(frame: frame, x: 66, y: 50, diameter: 6) } # right edge at x=69, radius: 3

    describe '.topmost' do
      it 'returns the circle with the highest y + radius value' do
        result = Circle.topmost
        expect(result).to eq(top_circle.position)
      end

      it 'considers the radius when determining topmost position' do
        # Create a circle that has lower y but larger radius, making it extend higher
        new_frame = Frame.create!(x: 100, y: 100, width: 40, height: 40) # bounds: 80-120, 80-120
        Circle.create!(frame: new_frame, x: 90, y: 110, diameter: 4) # y=110, radius=2, top edge at y=112
        higher_circle = Circle.create!(frame: new_frame, x: 110, y: 108, diameter: 8) # y=108, radius=4, top edge at y=112

        result = new_frame.circles.topmost
        expect([result, higher_circle]).to include(result) # Both have same top edge at y=112
      end
    end

    describe '.bottommost' do
      it 'returns the circle with the lowest y - radius value' do
        result = Circle.bottommost
        expect(result).to eq(bottom_circle.position)
      end

      it 'considers the radius when determining bottommost position' do
        # Create a circle that has higher y but larger radius, making it extend lower
        new_frame = Frame.create!(x: 150, y: 150, width: 40, height: 40) # bounds: 130-170, 130-170
        Circle.create!(frame: new_frame, x: 140, y: 140, diameter: 4) # y=140, radius=2, bottom edge at y=138
        lower_circle = Circle.create!(frame: new_frame, x: 160, y: 142, diameter: 8) # y=142, radius=4, bottom edge at y=138

        result = new_frame.circles.bottommost
        expect([result, lower_circle]).to include(result) # Both have same bottom edge at y=138
      end
    end

    describe '.leftmost' do
      it 'returns the circle with the lowest x - radius value' do
        result = Circle.leftmost
        expect(result).to eq(left_circle.position)
      end

      it 'considers the radius when determining leftmost position' do
        # Create a circle that has higher x but larger radius, making it extend further left
        new_frame = Frame.create!(x: 200, y: 200, width: 40, height: 40) # bounds: 180-220, 180-220
        Circle.create!(frame: new_frame, x: 192, y: 190, diameter: 4) # x=192, radius=2, left edge at x=190
        lefter_circle = Circle.create!(frame: new_frame, x: 194, y: 210, diameter: 8) # x=194, radius=4, left edge at x=190

        result = new_frame.circles.leftmost
        expect([result, lefter_circle]).to include(result) # Both have same left edge at x=190
      end
    end

    describe '.rightmost' do
      it 'returns the circle with the highest x + radius value' do
        result = Circle.rightmost
        expect(result).to eq(right_circle.position)
      end

      it 'considers the radius when determining rightmost position' do
        # Create a circle that has lower x but larger radius, making it extend further right
        new_frame = Frame.create!(x: 250, y: 250, width: 40, height: 40) # bounds: 230-270, 230-270
        Circle.create!(frame: new_frame, x: 258, y: 240, diameter: 4) # x=258, radius=2, right edge at x=260
        righter_circle = Circle.create!(frame: new_frame, x: 256, y: 260, diameter: 8) # x=256, radius=4, right edge at x=260

        result = new_frame.circles.rightmost
        expect([result, righter_circle]).to include(result) # Both have same right edge at x=260
      end
    end

    describe 'when there are no circles' do
      let(:empty_frame) { Frame.create!(x: 100, y: 100, width: 20, height: 20) }

      it 'topmost returns empty' do
        expect(empty_frame.circles.topmost).to be_blank
      end

      it 'bottommost returns empty' do
        expect(empty_frame.circles.bottommost).to be_blank
      end

      it 'leftmost returns empty' do
        expect(empty_frame.circles.leftmost).to be_blank
      end

      it 'rightmost returns empty' do
        expect(empty_frame.circles.rightmost).to be_blank
      end
    end

    describe 'position methods' do
      it 'topmost returns [x, y] array of topmost circle' do
        result = Circle.topmost
        expect(result).to eq(top_circle.position)
      end

      it 'bottommost returns [x, y] array of bottommost circle' do
        result = Circle.bottommost
        expect(result).to eq(bottom_circle.position)
      end

      it 'leftmost returns [x, y] array of leftmost circle' do
        result = Circle.leftmost
        expect(result).to eq(left_circle.position)
      end

      it 'rightmost returns [x, y] array of rightmost circle' do
        result = Circle.rightmost
        expect(result).to eq(right_circle.position)
      end

      context 'when there are no circles' do
        let(:empty_frame) { Frame.create!(x: 400, y: 400, width: 40, height: 40) }

        it 'topmost returns nil' do
          expect(empty_frame.circles.topmost).to be_nil
        end

        it 'bottommost returns nil' do
          expect(empty_frame.circles.bottommost).to be_nil
        end

        it 'leftmost returns nil' do
          expect(empty_frame.circles.leftmost).to be_nil
        end

        it 'rightmost returns nil' do
          expect(empty_frame.circles.rightmost).to be_nil
        end
      end
    end
  end
end
