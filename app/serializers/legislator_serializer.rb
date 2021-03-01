class LegislatorSerializer < ActiveModel::Serializer
  attributes :id, :name, :party, :chamber, :district, :twitter, :email, :image, :geo, :role, :committees, :contact_infos, :note

  def note
    note = self.object.notes.find_by(user_id: current_user.id)
    if note
      return note    
    else
      return ""
    end

  end

end