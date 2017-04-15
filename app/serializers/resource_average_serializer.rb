class ResourceAverageSerializer < ActiveModel::Serializer
  attributes :quantity_average
  attribute(:resource) { object.resource.name }
end