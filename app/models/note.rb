class Note < ApplicationRecord
  belongs_to :user
  belongs_to :legislator

  validates :user_id, uniqueness: {scope: :legislator_id}
end
