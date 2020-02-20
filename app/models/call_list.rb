class CallList < ApplicationRecord
  belongs_to :campaign
  has_many :calls
end
