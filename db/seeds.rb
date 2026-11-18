# Datos de ejemplo para probar el back-office y el front-end.
# Se puede ejecutar varias veces: `bin/rails db:seed` (o `bin/rails db:seed:replant` para empezar de cero).
# En el deploy (Render) se corre en cada arranque para que siempre haya funciones de hoy en adelante.

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
# [clave, título, género, duración (min), clasificación, estreno original, sinopsis]
movie_data = [
  [ :sw1, "Star Wars: Episodio I - La amenaza fantasma", "Ciencia ficción", 136, "ATP", "1999-05-19",
    "Dos caballeros Jedi descubren en el planeta Tatooine a Anakin Skywalker, un niño esclavo con una conexión extraordinaria con la Fuerza, mientras la República enfrenta un bloqueo comercial que esconde un plan mucho mayor." ],
  [ :sw2, "Star Wars: Episodio II - El ataque de los clones", "Ciencia ficción", 142, "ATP", "2002-05-16",
    "Diez años después, Anakin es el aprendiz de Obi-Wan Kenobi y debe proteger a la senadora Padmé Amidala, mientras un movimiento separatista amenaza con llevar a la galaxia a la guerra." ],
  [ :sw3, "Star Wars: Episodio III - La venganza de los Sith", "Ciencia ficción", 140, "+13", "2005-05-19",
    "Las Guerras Clon llegan a su fin y Anakin, atormentado por visiones, queda atrapado entre su lealtad a los Jedi y las promesas del canciller Palpatine." ],
  [ :sw4, "Star Wars: Episodio IV - Una nueva esperanza", "Ciencia ficción", 121, "ATP", "1977-05-25",
    "Luke Skywalker, un joven granjero, se une a un viejo Jedi, a un contrabandista y a dos droides para rescatar a la princesa Leia y enfrentar a la temible Estrella de la Muerte." ],
  [ :sw5, "Star Wars: Episodio V - El imperio contraataca", "Ciencia ficción", 124, "ATP", "1980-05-21",
    "Tras una derrota en el planeta helado Hoth, los rebeldes se dispersan: Luke viaja a entrenar con el maestro Yoda mientras Han y Leia son perseguidos por Darth Vader." ],
  [ :sw6, "Star Wars: Episodio VI - El regreso del Jedi", "Ciencia ficción", 131, "ATP", "1983-05-25",
    "Luke rescata a Han Solo y se prepara para enfrentar a Vader y al Emperador, mientras la Alianza Rebelde organiza un ataque final contra una nueva Estrella de la Muerte." ],
  [ :sw7, "Star Wars: Episodio VII - El despertar de la Fuerza", "Ciencia ficción", 138, "+13", "2015-12-17",
    "Treinta años después de la caída del Imperio, Rey, una chatarrera, y Finn, un soldado desertor, se ven envueltos en la lucha de la Resistencia contra la Primera Orden." ],
  [ :sw8, "Star Wars: Episodio VIII - Los últimos Jedi", "Ciencia ficción", 152, "+13", "2017-12-14",
    "Rey busca a Luke Skywalker en una isla remota para aprender los caminos de la Fuerza, mientras la Resistencia escapa de la persecución de la Primera Orden." ],
  [ :sw9, "Star Wars: Episodio IX - El ascenso de Skywalker", "Ciencia ficción", 141, "+13", "2019-12-19",
    "La Resistencia enfrenta el regreso de un antiguo enemigo, y Rey debe descubrir la verdad sobre su origen en la batalla final de la saga Skywalker." ],
  [ :hp1, "Harry Potter y la piedra filosofal", "Fantasía", 152, "ATP", "2001-11-16",
    "En su cumpleaños número once, Harry descubre que es un mago y empieza su primer año en el Colegio Hogwarts de Magia y Hechicería, donde lo espera un misterio escondido." ],
  [ :hp2, "Harry Potter y la cámara secreta", "Fantasía", 161, "ATP", "2002-11-15",
    "En su segundo año, una serie de ataques deja a varios alumnos petrificados y Harry, Ron y Hermione investigan la leyenda de la Cámara Secreta." ],
  [ :hp3, "Harry Potter y el prisionero de Azkaban", "Fantasía", 142, "ATP", "2004-05-31",
    "Sirius Black escapa de la prisión de Azkaban y todos creen que va tras Harry, mientras los dementores custodian Hogwarts." ],
  [ :hp4, "Harry Potter y el cáliz de fuego", "Fantasía", 157, "+13", "2005-11-18",
    "Harry es elegido de forma misteriosa para competir en el Torneo de los Tres Magos, una serie de pruebas peligrosas que terminan en un encuentro inesperado." ],
  [ :hp5, "Harry Potter y la Orden del Fénix", "Fantasía", 138, "+13", "2007-07-11",
    "Nadie quiere creer que Voldemort regresó. Harry organiza un grupo secreto de alumnos para prepararse ante la amenaza, mientras el Ministerio controla Hogwarts." ],
  [ :hp6, "Harry Potter y el misterio del príncipe", "Fantasía", 153, "+13", "2009-07-15",
    "Dumbledore prepara a Harry para la batalla final explorando el pasado de Voldemort, mientras un viejo libro de pociones esconde los secretos de su dueño anterior." ],
  [ :hp7a, "Harry Potter y las reliquias de la Muerte - Parte 1", "Fantasía", 146, "+13", "2010-11-19",
    "Harry, Ron y Hermione dejan Hogwarts para buscar y destruir los Horrocruxes, la clave para derrotar a Voldemort, mientras el mundo mágico cae bajo su control." ],
  [ :hp7b, "Harry Potter y las reliquias de la Muerte - Parte 2", "Fantasía", 130, "+13", "2011-07-15",
    "La búsqueda de los Horrocruxes lleva a Harry y sus amigos de regreso a Hogwarts, donde se libra la batalla final contra Voldemort." ]
]

movies = movie_data.to_h do |key, title, genre, minutes, rating, released_on, synopsis|
  movie = Movie.find_or_create_by!(title: title) do |m|
    m.genre = genre
    m.duration_minutes = minutes
    m.rating = rating
    m.status = :now_showing
    m.release_date = Date.parse(released_on)
    m.synopsis = synopsis
  end
  [ key, movie ]
end

puts "Creando funciones..."
# Grilla diaria por sala: [película, hora, formato, idioma, precio].
# Entre una función y la siguiente queda la duración + 20 min de limpieza.
schedule = {
  centro_4: [ # IMAX
    [ :sw9, "11:00", :imax, :subtitled, 9000 ],
    [ :sw7, "14:00", :imax, :dubbed, 9000 ],
    [ :sw8, "17:00", :imax, :subtitled, 9000 ],
    [ :hp7b, "20:15", :imax, :dubbed, 9000 ],
    [ :sw4, "23:00", :imax, :subtitled, 9000 ]
  ],
  centro_2: [ # 3D
    [ :hp1, "11:00", :two_d, :dubbed, 6000 ],
    [ :hp2, "14:10", :two_d, :subtitled, 6000 ],
    [ :hp3, "17:30", :three_d, :dubbed, 7500 ],
    [ :hp4, "20:30", :three_d, :subtitled, 7500 ]
  ],
  centro_1: [ # Estándar
    [ :sw1, "11:00", :two_d, :dubbed, 6000 ],
    [ :sw2, "14:00", :two_d, :subtitled, 6000 ],
    [ :sw3, "17:00", :two_d, :subtitled, 6000 ],
    [ :sw5, "20:00", :two_d, :dubbed, 6000 ],
    [ :sw6, "22:40", :two_d, :subtitled, 6000 ]
  ],
  shopping_1: [ # Estándar
    [ :hp5, "11:30", :two_d, :dubbed, 5500 ],
    [ :hp6, "14:30", :two_d, :subtitled, 5500 ],
    [ :hp7a, "17:45", :two_d, :dubbed, 5500 ],
    [ :hp7b, "20:50", :two_d, :subtitled, 5500 ]
  ]
}

screenings = []
(0..2).each do |day_offset|
  day = Date.current + day_offset
  schedule.each do |hall_key, slots|
    slots.each do |movie_key, time, format, language, price|
      screening = Screening.find_or_initialize_by(hall: halls[hall_key], starts_at: Time.zone.parse("#{day} #{time}"))
      if screening.new_record?
        screening.assign_attributes(movie: movies[movie_key], screen_format: format, language: language, price: price)
        # Si una función cargada a mano ocupa ese horario, se saltea en vez de cortar el arranque del servidor.
        next puts("  Se omite #{screening.starts_at} en #{screening.hall}: #{screening.errors.full_messages.to_sentence}") unless screening.save
      end
      screenings << screening
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
