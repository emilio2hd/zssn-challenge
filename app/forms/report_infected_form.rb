class ReportInfectedForm
  include ActiveModel::Model

  attr_accessor :survivor_id, :survivor_reporter_id
  attr_reader :infected

  validates :survivor_id, :survivor_reporter_id, presence: true
  validate :validate_survivor_exists, :validate_survivor_reported

  private

  def validate_survivor_exists
    @infected = Survivor.find_by_id survivor_id
    errors.add(:survivor_id, :not_found) if @infected.nil?
  end

  def validate_survivor_reported
    if InfectedFlag.exists?(infected_id: survivor_id, reporter_id: survivor_reporter_id)
      errors.add(:survivor_id, :has_been_reported_by_you)
    end
  end
end