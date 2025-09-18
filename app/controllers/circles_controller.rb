class CirclesController < ApplicationController
  before_action :set_circle, only: %i[ update destroy ]

  def index
    @circles = Circle.all

    render json: @circles
  end

  def create
    @circle = Circle.new(circle_params)
    @circle.frame_id = params[:frame_id]

    if @circle.save
      render json: @circle, status: :created, location: @circle
    else
      render json: @circle.errors, status: :unprocessable_content
    end
  end

  def update
    if @circle.update(circle_params)
      render json: @circle
    else
      render json: @circle.errors, status: :unprocessable_content
    end
  end

  def destroy
    @circle.destroy!
  end

  private
    def set_circle
      @circle = Circle.find(params.expect(:id))
    end

    def circle_params
      params.fetch(:circle, {}).permit(:x, :y, :diameter)
    end
end
