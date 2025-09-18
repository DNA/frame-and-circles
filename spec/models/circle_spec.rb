require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'associations' do
    it { should belong_to(:frame) }
  end

  describe 'validations' do
    it { should validate_presence_of(:frame) }
    it { should validate_numericality_of(:x) }
    it { should validate_numericality_of(:y) }
    it { should validate_numericality_of(:diameter).is_greater_than(0) }
  end
end
