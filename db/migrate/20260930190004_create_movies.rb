class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.text :synopsis
      t.string :genre, null: false
      t.integer :duration_minutes, null: false
      t.string :rating, null: false
      t.integer :status, null: false, default: 0
      t.date :release_date

      t.timestamps
    end
  end
end
