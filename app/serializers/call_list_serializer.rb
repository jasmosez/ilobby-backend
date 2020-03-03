class CallListSerializer < ActiveModel::Serializer
  attributes :id, :name, :campaign, :calls, :call_actions, :created_at, :updated_at
end