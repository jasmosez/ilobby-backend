class CreateCommittees < ActiveRecord::Migration[6.0]
  def change
    create_table :committees do |t|
      t.string :name
      t.string :chamber
      t.string :open_states_id

      t.timestamps
    end
  end
end
