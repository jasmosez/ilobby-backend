class Call < ApplicationRecord
  belongs_to :action
  belongs_to :call_list
end
