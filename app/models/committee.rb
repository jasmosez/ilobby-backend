class Committee < ApplicationRecord
  has_many :committee_legislators
  has_many :legislators, through: :committee_legislators
end
