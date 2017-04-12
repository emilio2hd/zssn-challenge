class InfectedFlag < ApplicationRecord
  belongs_to :infected, class_name: 'Survivor', foreign_key: 'infected_id', counter_cache: :flags_count
  belongs_to :reporter, class_name: 'Survivor', foreign_key: 'reporter_id'

  validates :infected, :reporter, presence: true

  after_create :check_survivor_status

  def check_survivor_status
    infected.check_status
  end
end
