json.partial! "api/v1/screenings/screening", screening: @screening
json.movie { json.extract! @screening.movie, :id, :title, :duration_minutes, :rating }
json.ends_at @screening.ends_at
json.service_fee_rate Order::SERVICE_FEE_RATE
json.seats @screening.hall.seats do |seat|
  json.extract! seat, :id, :row, :number, :accessible
  json.label seat.label
  json.taken @taken_seat_ids.include?(seat.id)
end
