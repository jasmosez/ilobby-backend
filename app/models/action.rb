class Action < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_one :call, dependent: :destroy
  has_many :legislators
end
