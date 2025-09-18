require 'rails_helper'

RSpec.describe Frame, type: :model do
  describe 'associations' do
    it { should have_many(:circles) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:x) }
    it { should validate_numericality_of(:y) }
    it { should validate_numericality_of(:width).is_greater_than(0) }
    it { should validate_numericality_of(:height).is_greater_than(0) }
  end
end
