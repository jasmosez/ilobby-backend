class AddCommitmentToCalls < ActiveRecord::Migration[6.0]
  def change
    add_column :calls, :commitment, :string
  end
end
