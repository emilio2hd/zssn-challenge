require 'rails_helper'

RSpec.describe Resource, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(50) }
  it { is_expected.to validate_presence_of(:points) }
  it { is_expected.to validate_numericality_of(:points).is_greater_than(0).only_integer }

  describe '.all_cached', caching: true do
    context 'when cache is empty' do
      let(:water) { create(:water) }
      let(:resource_list) { [water] }

      it 'should call from database' do
        expect(Resource).to receive(:all).once.and_return(resource_list)
        expect(Resource.all_cached).to eq(resource_list)
      end
    end

    context 'when cache is populated' do
      before do
        @resource_list = [create(:water)]
        Resource.all_cached
      end

      it 'should not call from database' do
        expect(Resource).to_not receive(:all)
        expect(Resource.all_cached).to eq(@resource_list)
      end
    end
  end

  describe '.find_by_name_cached', caching: true do
    before { Rails.cache.clear }

    context 'when cache is empty' do
      let(:water) { create(:water) }
      let(:resource_list) { [water] }

      it 'should return the resource' do
        expect(Resource).to receive(:all).once.and_return(resource_list)
        expect(Resource.find_by_name_cached(water.name)).to eq(water)
      end
    end

    context 'when name does not exist' do
      let(:water) { create(:water) }
      let(:resource_list) { [water] }

      it 'should return nil' do
        expect(Resource).to receive(:all).once.and_return(resource_list)
        expect(Resource.find_by_name_cached('Fuel')).to be_nil
      end
    end
  end
end
