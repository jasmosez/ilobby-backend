class AddCompleteToActions < ActiveRecord::Migration[6.0]
  def change
    add_column :actions, :complete, :boolean
  end
end
