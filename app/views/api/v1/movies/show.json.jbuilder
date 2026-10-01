json.partial! "api/v1/movies/movie", movie: @movie
json.synopsis @movie.synopsis
json.screenings @screenings do |screening|
  json.partial! "api/v1/screenings/screening", screening: screening
end
