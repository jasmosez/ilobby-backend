class CreateActions < ActiveRecord::Migration[6.0]
  def change
    create_table :actions do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :campaign, null: false, foreign_key: true
      t.belongs_to :legislator, null: false, foreign_key: true
      t.string :type
      t.string :status
      t.datetime :date

      t.timestamps
    end
  end
end
