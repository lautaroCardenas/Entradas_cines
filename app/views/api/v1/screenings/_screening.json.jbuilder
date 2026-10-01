json.extract! screening, :id, :starts_at, :screen_format, :language, :price
json.format_label "#{t("enums.screening.screen_format.#{screening.screen_format}")} · #{t("enums.screening.language.#{screening.language}")}"
json.cinema { json.extract! screening.hall.cinema, :id, :name }
json.hall { json.extract! screening.hall, :id, :name, :hall_type }
json.available_seats screening.available_seats_count
json.sold_out screening.sold_out?
