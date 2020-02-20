class CreateCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :calls do |t|
      t.belongs_to :action, null: false, foreign_key: true
      t.string :status
      t.string :outcome
      t.datetime :date
      t.integer :duration
      t.string :notes
      t.belongs_to :call_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
