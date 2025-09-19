class Frame < ApplicationRecord
  has_many :circles
  validates_associated :circles
  accepts_nested_attributes_for :circles

  composed_of :edge, class_name: "Values::FrameEdge",
                     mapping: [ %i[x x], %i[y y], %i[width width], %i[height height] ]

  validates :x, :y, numericality: true
  validates :width, :height, numericality: { greater_than: 0 }
  validate :overlapping_frames

  scope :right_edge, ->(boundary) { where("x + width / 2.0 > ?", boundary) }
  scope :left_edge, ->(boundary) { where("x - width / 2.0 < ?", boundary) }
  scope :top_edge, ->(boundary) { where("y + height / 2.0 > ?", boundary) }
  scope :bottom_edge, ->(boundary) { where("y - height / 2.0 < ?", boundary) }

  def destroyable?
    return true unless circles.exists?

    errors.add(:base, "Can't destroy a frame with circles")
    false
  end

  def destroy
    return super if destroyable?

    false
  end

  private

  def overlapping_frames
    clear_aggregation_cache

    errors.add(:base, "Frame overlaps with existing frame(s)") if overlap_with_others?
  end

  def overlap_with_others?
    Frame.right_edge(edge.left)
      .left_edge(edge.right)
      .top_edge(edge.bottom)
      .bottom_edge(edge.top)
      .where.not(id: id)
      .exists?
  end
end
