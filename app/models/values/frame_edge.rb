module Values
  class FrameEdge
    attr_reader :x, :y, :width, :height

    def initialize(x, y, width, height)
      @x, @y, @width, @height =  x, y, width, height
    end

    def left
      return if x.blank? or width.blank?

      x - width / 2.0
    end

    def right
      return if x.blank? or width.blank?

      x + width / 2.0
    end

    def bottom
      return if y.blank? or height.blank?

      y - height / 2.0
    end

    def top
      return if y.blank? or height.blank?

      y + height / 2.0
    end
  end
end
