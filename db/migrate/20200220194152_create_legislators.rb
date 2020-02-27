class CreateLegislators < ActiveRecord::Migration[6.0]
  def change
    create_table :legislators do |t|
      t.string :name
      t.string :family_name
      t.string :given_name
      t.string :party
      t.string :chamber
      t.integer :district
      t.string :twitter
      t.string :email
      t.string :image
      t.string :open_states_id
      t.string :geo
      t.string :role

      t.timestamps
    end
  end
end
