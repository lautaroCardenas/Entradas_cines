class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats do |t|
      t.references :hall, null: false, foreign_key: true
      t.string :row, null: false
      t.integer :number, null: false
      t.boolean :accessible, null: false, default: false

      t.timestamps
    end
    add_index :seats, [ :hall_id, :row, :number ], unique: true
  end
end
