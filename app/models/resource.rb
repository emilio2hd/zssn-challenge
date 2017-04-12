class Resource < ApplicationRecord
  validates :name, :points, presence: true
  validates :name, length: { maximum: 50 }
  validates :points, numericality: { only_integer: true, greater_than: 0 }
end
