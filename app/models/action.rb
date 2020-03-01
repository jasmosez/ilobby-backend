class Action < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_one :call
  has_many :legislators
end
