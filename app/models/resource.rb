class Resource < ApplicationRecord
  validates :name, :points, presence: true
  validates :name, length: { maximum: 50 }
  validates :points, numericality: { only_integer: true, greater_than: 0 }

  class << self
    def all_cached
      Rails.cache.fetch 'resources/all' do
        all.to_a
      end
    end

    def find_by_name_cached(name)
      raise 'Name cant be empty' if name.to_s.empty?
      all_cached.find { |resource| resource.name.casecmp(name.downcase).zero? }
    end
  end
end