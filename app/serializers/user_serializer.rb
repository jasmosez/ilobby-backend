class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :campaigns, :actions, :call_lists, :calls

end