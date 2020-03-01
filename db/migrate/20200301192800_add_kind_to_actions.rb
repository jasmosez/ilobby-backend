class AddKindToActions < ActiveRecord::Migration[6.0]
  def change
    add_column :actions, :kind, :string
  end
end
