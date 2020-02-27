class CreateContactInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_infos do |t|
      t.string :kind
      t.string :value
      t.string :note
      t.belongs_to :legislator, null: false, foreign_key: true

      t.timestamps
    end
  end
end
