class RemoveTypeFromActions < ActiveRecord::Migration[6.0]
  def change
    remove_column :actions, :type
  end
end
