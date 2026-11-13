json.extract! order, :id, :status, :service_fee, :total, :created_at
json.cancellable order.cancellable_by_customer?
json.screening do
  json.extract! order.screening, :id, :starts_at, :screen_format, :language
  json.format_label "#{t("enums.screening.screen_format.#{order.screening.screen_format}")} · #{t("enums.screening.language.#{order.screening.language}")}"
  json.movie order.screening.movie.title
  json.movie_id order.screening.movie_id
  json.cinema order.screening.hall.cinema.name
  json.hall order.screening.hall.name
end
json.tickets order.tickets.sort_by { |t| [ t.seat.row, t.seat.number ] } do |ticket|
  json.extract! ticket, :id, :code, :price
  json.seat ticket.seat.label
end
