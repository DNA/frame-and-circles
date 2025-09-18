class Frame < ApplicationRecord
  has_many :circles
  validates_associated :circles

  validates :x, :y, numericality: true
  validates :width, :height, numericality: { greater_than: 0 }
end
