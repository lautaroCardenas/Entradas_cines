class CreateScreenings < ActiveRecord::Migration[8.1]
  def change
    create_table :screenings do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :hall, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer :screen_format, null: false, default: 0
      t.integer :language, null: false, default: 0
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
    add_index :screenings, [ :hall_id, :starts_at ]
  end
end
