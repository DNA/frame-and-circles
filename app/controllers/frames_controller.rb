class FramesController < ApplicationController
  before_action :set_frame, only: %i[ show destroy ]

  def show
    render json: @frame
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
    @frame.destroy!
  end

  private
    def set_frame
      @frame = Frame.find(params.expect(:id))
    end

    def frame_params
      params.fetch(:frame, {}).permit(:x, :y, :width, :height)
    end
end
