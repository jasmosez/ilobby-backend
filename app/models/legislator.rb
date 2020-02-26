class Legislator < ApplicationRecord
  has_many :committee_legislators
  has_many :committees, through: :committee_legislators
  has_many :legislator_actions
  has_many :actions, through: :legislator_actions
  has_many :contact_infos
end
