class CreateLegislatorContactInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :legislator_contact_infos do |t|
      t.belongs_to :legislator, null: false, foreign_key: true
      t.belongs_to :contact_info, null: false, foreign_key: true

      t.timestamps
    end
  end
end
