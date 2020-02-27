class LegislatorSerializer < ActiveModel::Serializer
  attributes :id, :name, :party, :chamber, :district, :twitter, :email, :image, :geo, :role, :committees, :contact_infos
end