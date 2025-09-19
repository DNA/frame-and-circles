class FramesController < ApplicationController
  before_action :set_frame, only: %i[ show destroy ]

  def show

    render json: {
      x: @frame.x,
      y: @frame.y,
      circle_count: @frame.circles.count,
      topmost_position: @frame.circles.topmost.presence,
      bottommost_position: @frame.circles.bottommost.presence,
      leftmost_position: @frame.circles.leftmost.presence,
      rightmost_position: @frame.circles.rightmost.presence,
    }
  end

  def create
    @frame = Frame.new(frame_params)

    if @frame.save
      render json: @frame, status: :created, location: @frame
    else
      render json: @frame.errors, status: :unprocessable_content
    end
  end

  def destroy
    if @frame.destroy
      render json: @frame, status: :no_content
    else
      render json: @frame.errors, status: :unprocessable_content
    end
  end

  private
    def set_frame
      @frame = Frame.find(params.expect(:id))
    end

    def frame_params
      params.fetch(:frame, {}).permit(:x, :y, :width, :height, { circles_attributes: %i[x y diameter ] })
    end
end
