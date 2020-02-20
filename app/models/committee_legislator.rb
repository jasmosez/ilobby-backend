class CommitteeLegislator < ApplicationRecord
  belongs_to :legislator
  belongs_to :committee
end
