class User < ApplicationRecord
  has_many :actions
  has_many :campaigns
  has_many :calls, through: :actions
end
