# Migración de datos: borra las películas de ejemplo originales (reemplazadas en
# los seeds por las sagas de Star Wars y Harry Potter) junto con sus funciones,
# compras y entradas. Se ejecuta una sola vez por base; solo toca esos títulos,
# así que no afecta las películas cargadas desde el back-office.
class RemoveOldSampleMovies < ActiveRecord::Migration[8.1]
  OLD_TITLES = [
    "El faro de sal", "Órbita baja", "Casa de verano", "Nueve lunas",
    "La última función", "Cuerpo celeste", "Marea alta"
  ].freeze

  def up
    movie_ids = select_values("SELECT id FROM movies WHERE title IN (#{quoted_list(OLD_TITLES)})").map(&:to_i)
    return if movie_ids.empty?

    screening_ids = select_values("SELECT id FROM screenings WHERE movie_id IN (#{movie_ids.join(',')})").map(&:to_i)
    if screening_ids.any?
      ids = screening_ids.join(",")
      execute "DELETE FROM tickets WHERE screening_id IN (#{ids})"
      execute "DELETE FROM tickets WHERE order_id IN (SELECT id FROM orders WHERE screening_id IN (#{ids}))"
      execute "DELETE FROM orders WHERE screening_id IN (#{ids})"
      execute "DELETE FROM screenings WHERE id IN (#{ids})"
    end
    execute "DELETE FROM active_storage_attachments WHERE record_type = 'Movie' AND record_id IN (#{movie_ids.join(',')})"
    execute "DELETE FROM movies WHERE id IN (#{movie_ids.join(',')})"
  end

  def down
    # Los datos borrados no se recuperan; los seeds cargan las películas nuevas.
  end

  private

  def quoted_list(values)
    values.map { |value| connection.quote(value) }.join(", ")
  end
end
