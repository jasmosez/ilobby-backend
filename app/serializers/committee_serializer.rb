class CommitteeSerializer < ActiveModel::Serializer
  attributes :id, :name, :chamber, :filter_name
end