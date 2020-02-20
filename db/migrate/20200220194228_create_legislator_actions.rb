class CreateLegislatorActions < ActiveRecord::Migration[6.0]
  def change
    create_table :legislator_actions do |t|
      t.belongs_to :action, null: false, foreign_key: true
      t.belongs_to :legislator, null: false, foreign_key: true

      t.timestamps
    end
  end
end
