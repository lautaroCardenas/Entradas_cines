class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.references :order, null: false, foreign_key: true
      t.references :screening, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :code, null: false

      t.timestamps
    end
    add_index :tickets, [ :screening_id, :seat_id ], unique: true
    add_index :tickets, :code, unique: true
  end
end
