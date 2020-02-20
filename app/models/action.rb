class Action < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_many :calls
  has_many :legislator_actions
  has_many :legislators, through: :legislator_actions
end
