class Committee < ApplicationRecord
  has_many :committee_legislators
  has_many :legislators, through: :committee_legislators

  def filter_name
    if self.chamber == "Assembly"
      return "(A) " + self.name
    
    elsif self.chamber == "House"
      return "(H) " + self.name
    
    else
      return "(S) " + self.name
    end
  end

end
