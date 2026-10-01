json.extract! order, :id, :status, :service_fee, :total, :created_at
json.screening do
  json.extract! order.screening, :id, :starts_at, :screen_format, :language
  json.movie order.screening.movie.title
  json.cinema order.screening.hall.cinema.name
  json.hall order.screening.hall.name
end
json.tickets order.tickets do |ticket|
  json.extract! ticket, :id, :code, :price
  json.seat ticket.seat.label
end
