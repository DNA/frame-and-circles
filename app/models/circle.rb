class Circle < ApplicationRecord
  belongs_to :frame

  composed_of :edge, class_name: "Values::CircleEdge",
                     mapping: [ %i[x x], %i[y y], %i[diameter diameter] ],
                     constructor: ->(x, y, d) { Values::CircleEdge.new(x: x, y: y, diameter: d) }

  validates :frame, presence: true
  validates :x, :y, numericality: true
  validates :diameter, numericality: { greater_than: 0 }
  validate :within_frame_boundaries
  validate :no_overlapping_circles

  scope :in_frame, ->(frame_id) { where(frame_id: frame_id) }

  # Use this and target circles positions to define a triangle,
  # then we check if its hypotenuse is smaller than both circles radiuses.
  scope :triangulate_overlapping, ->(x, y, radius) {
    where("SQRT(POWER(x - ?, 2) + POWER(y - ?, 2)) < (diameter / 2.0 + ?)", x, y, radius)
  }

  # Another pythagorean approach, used to find the distance between
  # the circle's centers. Then we check if the circle is inside with:
  # distance_between_centers + inner_circle_radius <= outer_circle_radius
  scope :within_edge, ->(edge) {
    where("SQRT(POWER(x - ?, 2) + POWER(y - ?, 2)) + (diameter / 2.0) <= ?", edge.x, edge.y, edge.radius)
  }

  def self.topmost
    order(Arel.sql("y + diameter/2.0 DESC")).pick(:x, :y)
  end

  def self.bottommost
    order(Arel.sql("y - diameter/2.0 ASC")).pick(:x, :y)
  end

  def self.leftmost
    order(Arel.sql("x - diameter/2.0 ASC")).pick(:x, :y)
  end

  def self.rightmost
    order(Arel.sql("x + diameter/2.0 DESC")).pick(:x, :y)
  end

  def position
    [ x, y ]
  end

  def radius
    return if diameter.blank?

    diameter / 2.0
  end

  private

  def within_frame_boundaries
    return if frame.blank?

    clear_aggregation_cache

    unless edge.within_frame?(frame.edge)
      errors.add(:base, "Circle must be within frame boundaries")
    end
  end

  def no_overlapping_circles
    return unless overlap_with_other_circles?

    errors.add(:base, "Circle overlaps with existing circle(s)")
  end

  def overlap_with_other_circles?
    Circle.in_frame(frame_id)
      .triangulate_overlapping(x, y, radius)
      .where.not(id: id)
      .exists?
  end
end
