class SurvivorItem < ApplicationRecord
  belongs_to :survivor
  belongs_to :resource

  validates :survivor, :resource, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end