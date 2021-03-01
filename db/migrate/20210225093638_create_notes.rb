class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :contents
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :legislator, null: false, foreign_key: true

      t.timestamps
    end
    add_index :notes, [:user_id, :legislator_id], unique: true
  end
end
