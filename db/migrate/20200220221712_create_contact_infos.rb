class CreateContactInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_infos do |t|
      t.string :type
      t.string :value
      t.string :note

      t.timestamps
    end
  end
end
