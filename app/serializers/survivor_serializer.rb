class SurvivorSerializer < ResumedSurvivorSerializer
  has_many :survivor_items, key: :inventory, serializer: SurvivorItemSerializer
end