class Action < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_many :calls
  has_many :legislators
end
