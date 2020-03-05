class Campaign < ApplicationRecord
  belongs_to :user

  has_many :actions, dependent: :destroy
  has_many :call_lists, dependent: :destroy
end
