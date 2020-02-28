class CallListSerializer < ActiveModel::Serializer
  attributes :id, :name, :campaign, :calls, :call_actions
end