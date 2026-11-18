# Contador de entradas vendidas por función (counter_cache). Evita contar las
# entradas con una consulta por cada función al listar horarios.
class AddTicketsCountToScreenings < ActiveRecord::Migration[8.1]
  def up
    add_column :screenings, :tickets_count, :integer, null: false, default: 0
    execute <<~SQL
      UPDATE screenings
      SET tickets_count = (SELECT COUNT(*) FROM tickets WHERE tickets.screening_id = screenings.id)
    SQL
  end

  def down
    remove_column :screenings, :tickets_count
  end
end
