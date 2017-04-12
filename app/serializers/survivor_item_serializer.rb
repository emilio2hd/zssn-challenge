class SurvivorItemSerializer < ActiveModel::Serializer
  attributes :quantity
  attribute(:resource) { object.resource.name }
end