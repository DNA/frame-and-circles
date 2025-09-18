class Circle < ApplicationRecord
  belongs_to :frame

  validates :frame, presence: true
  validates :x, :y, numericality: true
  validates :diameter, numericality: { greater_than: 0 }
end
