require 'rails_helper'

RSpec.describe SurvivorItem, type: :model do
  subject { build(:water_for_new_survivor) }

  it { is_expected.to validate_presence_of(:survivor) }
  it { is_expected.to validate_presence_of(:resource) }
  it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to belong_to(:survivor) }
  it { is_expected.to belong_to(:resource) }
  it { is_expected.to have_db_index([:survivor_id, :resource_id]).unique }
end