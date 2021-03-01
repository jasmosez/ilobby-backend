class Legislator < ApplicationRecord
  has_many :committee_legislators
  has_many :committees, through: :committee_legislators
  has_many :actions
  has_many :contact_infos
  has_many :notes
end
