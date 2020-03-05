class User < ApplicationRecord
  has_many :actions
  has_many :campaigns
  has_many :calls, through: :actions
  has_many :call_lists, through: :campaigns

  validates :email, uniqueness: true

  has_secure_password

end
