json.partial! "api/v1/movies/movie", movie: @movie
json.screenings @screenings do |screening|
  json.partial! "api/v1/screenings/screening", screening: screening
end
