class ResourceAverageSerializer < ActiveModel::Serializer
  attributes :quantity_average
  attribute :name, key: :resource
end