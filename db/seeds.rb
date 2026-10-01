# Datos de ejemplo para probar el back-office.
# Se puede ejecutar varias veces: `bin/rails db:seed` (o `bin/rails db:reset` para empezar de cero).

puts "Creando usuarios..."
admin = User.find_or_create_by!(email_address: "admin@salanorte.com") do |u|
  u.name = "Administrador"
  u.password = "password123"
  u.role = :admin
end

customers = [
  [ "María Rodríguez", "maria@example.com" ],
  [ "Juan Pérez", "juan@example.com" ],
  [ "Lucía Gómez", "lucia@example.com" ]
].map do |name, email|
  User.find_or_create_by!(email_address: email) do |u|
    u.name = name
    u.password = "password123"
  end
end

puts "Creando sedes y salas..."
centro = Cinema.find_or_create_by!(name: "Sala Norte Centro") do |c|
  c.address = "Av. San Martín 1234"
  c.city = "Mendoza"
end
shopping = Cinema.find_or_create_by!(name: "Sala Norte Shopping") do |c|
  c.address = "Panamericana 2650"
  c.city = "Godoy Cruz"
end

halls = {
  centro_1: [ centro, "Sala 1", :standard, 8, 12 ],
  centro_2: [ centro, "Sala 2", :three_d, 10, 14 ],
  centro_4: [ centro, "Sala 4", :imax, 8, 12 ],
  shopping_1: [ shopping, "Sala 1", :standard, 6, 10 ]
}.transform_values do |cinema, name, type, rows, per_row|
  Hall.find_or_create_by!(cinema: cinema, name: name) do |h|
    h.hall_type = type
    h.rows_count = rows
    h.seats_per_row = per_row
  end
end

# Primeros asientos de la última fila, aptos para movilidad reducida.
halls.each_value do |hall|
  hall.seats.where(row: Hall::ROW_LETTERS[hall.rows_count - 1], number: [ 1, 2 ]).update_all(accessible: true)
end

puts "Creando películas..."
movies = [
  [ "El faro de sal", "Drama", 118, "+13", :now_showing ],
  [ "Órbita baja", "Ciencia ficción", 132, "+13", :now_showing ],
  [ "Casa de verano", "Comedia", 101, "ATP", :now_showing ],
  [ "Nueve lunas", "Animación", 95, "ATP", :now_showing ],
  [ "La última función", "Suspenso", 123, "+16", :now_showing ],
  [ "Cuerpo celeste", "Documental", 89, "ATP", :now_showing ],
  [ "Marea alta", "Aventura", 110, "+13", :coming_soon ]
].to_h do |title, genre, minutes, rating, status|
  movie = Movie.find_or_create_by!(title: title) do |m|
    m.genre = genre
    m.duration_minutes = minutes
    m.rating = rating
    m.status = status
    m.synopsis = "Sinopsis de ejemplo de #{title}."
    m.release_date = status == :coming_soon ? 1.month.from_now.to_date : 2.weeks.ago.to_date
  end
  [ title, movie ]
end

puts "Creando funciones..."
schedule = [
  [ "Órbita baja", :centro_4, "14:30", :imax, :dubbed, 9000 ],
  [ "Órbita baja", :centro_4, "17:45", :imax, :dubbed, 9000 ],
  [ "Órbita baja", :centro_4, "21:00", :imax, :subtitled, 9000 ],
  [ "Nueve lunas", :centro_2, "15:00", :three_d, :dubbed, 7500 ],
  [ "La última función", :centro_2, "18:15", :two_d, :subtitled, 6000 ],
  [ "El faro de sal", :centro_1, "16:20", :two_d, :subtitled, 6000 ],
  [ "Casa de verano", :centro_1, "19:30", :two_d, :dubbed, 6000 ],
  [ "Cuerpo celeste", :shopping_1, "20:00", :two_d, :subtitled, 5500 ]
]

screenings = []
(0..2).each do |day_offset|
  day = Date.current + day_offset
  schedule.each do |title, hall_key, time, format, language, price|
    starts_at = Time.zone.parse("#{day} #{time}")
    screenings << Screening.find_or_create_by!(hall: halls[hall_key], starts_at: starts_at) do |s|
      s.movie = movies[title]
      s.screen_format = format
      s.language = language
      s.price = price
    end
  end
end

puts "Creando compras..."
if Order.none?
  screenings.first(6).each_with_index do |screening, i|
    free_seats = screening.hall.seats.where.not(id: screening.taken_seat_ids).limit(i % 3 + 1)
    order = Order.new(user: customers[i % customers.size], screening: screening, status: i.even? ? :paid : :pending)
    order.assign_seats(free_seats.ids)
    order.save!
  end
end

puts "Listo. Back-office: admin@salanorte.com / password123 (usuario: #{admin.name})"
