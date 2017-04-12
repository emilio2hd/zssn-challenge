require 'rails_helper'

RSpec.describe InfectedFlag, type: :model do
  it { is_expected.to validate_presence_of(:infected) }
  it { is_expected.to validate_presence_of(:reporter) }
  it { is_expected.to have_db_index([:infected_id, :reporter_id]).unique }

  it 'should notify infected to check status' do
    infected = create(:full_new_survivor)
    reporter = create(:full_new_survivor)

    expect(infected).to receive(:check_status)

    InfectedFlag.create(infected: infected, reporter: reporter)
  end
end
