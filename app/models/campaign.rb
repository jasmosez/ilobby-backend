class Campaign < ApplicationRecord
  belongs_to :user

  has_many :actions
  has_many :call_lists
end
