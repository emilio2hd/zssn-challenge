require 'rails_helper'

RSpec.describe Survivor, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it { is_expected.to validate_presence_of(:gender) }
  it { is_expected.to validate_presence_of(:last_location) }
  it { is_expected.to define_enum_for(:status).with([:alive, :infected]) }
  it { is_expected.to define_enum_for(:gender).with([:female, :male, :other]) }

  context 'When last_location is informed' do
    let(:new_survivor) { build(:new_survivor) }

    before { new_survivor.save }

    it 'Should split location string position into decimal' do
      expect(new_survivor.last_location_lati).not_to be_nil
      expect(new_survivor.last_location_lati).to be_a_kind_of(BigDecimal)
      expect(new_survivor.last_location_long).not_to be_nil
      expect(new_survivor.last_location_long).to be_a_kind_of(BigDecimal)
    end
  end
end
