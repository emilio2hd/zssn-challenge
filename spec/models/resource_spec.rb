require 'rails_helper'

RSpec.describe Resource, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(50) }
  it { is_expected.to validate_presence_of(:points) }
  it { is_expected.to validate_numericality_of(:points).is_greater_than(0).only_integer }
end
