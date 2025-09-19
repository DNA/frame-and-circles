module Values
  class CircleEdge
    attr_reader :x, :y, :diameter

    def initialize(x, y, diameter)
      @x, @y, @diameter = x, y, diameter
    end

    def radius
      return if diameter.blank?

      diameter / 2.0
    end

    def left
      return if x.blank? || radius.blank?

      x - radius
    end

    def right
      return if x.blank? || radius.blank?

      x + radius
    end

    def bottom
      return if y.blank? || radius.blank?

      y - radius
    end

    def top
      return if y.blank? || radius.blank?

      y + radius
    end

    # Check if this circle is within the given frame bounds (can touch edges)
    def within_frame?(frame_edge)
      return false if left.blank? || right.blank? || top.blank? || bottom.blank?
      return false if frame_edge.left.blank? || frame_edge.right.blank? || frame_edge.top.blank? || frame_edge.bottom.blank?

      left >= frame_edge.left &&
        right <= frame_edge.right &&
        bottom >= frame_edge.bottom &&
        top <= frame_edge.top
    end
  end
end
