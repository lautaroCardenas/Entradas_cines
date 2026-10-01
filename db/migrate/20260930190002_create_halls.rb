class CreateHalls < ActiveRecord::Migration[8.1]
  def change
    create_table :halls do |t|
      t.references :cinema, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :hall_type, null: false, default: 0
      t.integer :rows_count, null: false
      t.integer :seats_per_row, null: false

      t.timestamps
    end
    add_index :halls, [ :cinema_id, :name ], unique: true
  end
end
