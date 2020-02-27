class LegislatorContactInfo < ApplicationRecord
  belongs_to :legislator
  belongs_to :contact_info
end
