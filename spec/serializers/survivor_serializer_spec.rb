require 'rails_helper'

RSpec.describe SurvivorSerializer, type: :serializer do
  before(:all) do
    @survivor = create(:full_new_survivor)

    @serializer = SurvivorSerializer.new(@survivor)

    @serialization = ActiveModelSerializers::Adapter.create(@serializer)
  end

  subject { JSON.parse(@serialization.to_json) }

  it 'should have a id that matches' do
    expect(subject['survivor']['id']).to eql(@survivor.id)
  end

  it 'should have a name that matches' do
    expect(subject['survivor']['name']).to eql(@survivor.name)
  end

  it 'should have a age that matches' do
    expect(subject['survivor']['age']).to eql(@survivor.age)
  end

  it 'should have a gender that matches' do
    expect(subject['survivor']['gender']).to eql(@survivor.gender)
  end

  it 'should have a last_location that matches' do
    expect(subject['survivor']['last_location']).to eql(@survivor.last_location)
  end

  it 'should have inventory key' do
    expect(subject['survivor']).to have_key('inventory')
  end

  it 'should have a link to inventory' do
    expect(subject['survivor']['links']['self']).to eql(v1_survivor_path(@survivor.id))
  end
end