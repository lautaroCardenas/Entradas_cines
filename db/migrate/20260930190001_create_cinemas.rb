class CreateCinemas < ActiveRecord::Migration[8.1]
  def change
    create_table :cinemas do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :city, null: false

      t.timestamps
    end
    add_index :cinemas, :name, unique: true
  end
end
