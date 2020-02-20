class CreateCallLists < ActiveRecord::Migration[6.0]
  def change
    create_table :call_lists do |t|
      t.belongs_to :campaign, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
