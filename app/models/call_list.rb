class CallList < ApplicationRecord
  belongs_to :campaign
  has_many :calls

  def call_actions
    self.calls.map do |call|
      call.action
    end
  end
  
  def call_action_legislators
    self.call_actions.map do |action|
      action.legislators
    end
  end
end
