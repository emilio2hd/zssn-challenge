class ResumedSurvivorSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :age, :gender, :last_location

  attribute :last_location do
    object.combined_last_location
  end

  attribute :links do
    { self: v1_survivor_path(object.id) }
  end
end