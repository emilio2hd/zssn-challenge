require 'rails_helper'

RSpec.describe ReportInfectedForm, type: :model do
  let(:report_infected_params) { {} }
  it { is_expected.to validate_presence_of(:survivor_id) }
  it { is_expected.to validate_presence_of(:survivor_reporter_id) }

  subject { ReportInfectedForm.new(report_infected_params) }

  describe 'custom validations' do
    context 'when survivor to be reported as infected does not exist' do
      let(:report_infected_params) { { survivor_id: -1, survivor_reporter_id: 1 } }

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.details[:survivor_id]).to eq([{ error: :not_found }])
      end
    end

    context 'when survivor has been reported for the same reporter' do
      let(:infected) { create(:full_new_survivor) }
      let(:reporter) { create(:full_new_survivor) }
      let(:report_infected_params) { { survivor_id: infected.id, survivor_reporter_id: reporter.id } }

      before { create(:flag, infected: infected, reporter: reporter) }

      it 'should be invalid' do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.details[:survivor_id]).to eq([{ error: :has_been_reported_by_you }])
      end
    end

    context 'when params are correct' do
      let(:infected) { create(:full_new_survivor) }
      let(:reporter) { create(:full_new_survivor) }
      let(:report_infected_params) { { survivor_id: infected.id, survivor_reporter_id: reporter.id } }

      it 'should be valid' do
        expect(subject.valid?).to be_truthy
      end
    end
  end
end