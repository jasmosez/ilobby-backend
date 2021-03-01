class User < ApplicationRecord
  has_many :actions
  has_many :campaigns
  has_many :calls, through: :actions
  has_many :call_lists, through: :campaigns
  has_many :notes

  validates :user_id, uniqueness: true

end
