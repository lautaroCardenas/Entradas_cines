json.array! @movies do |movie|
  json.partial! "api/v1/movies/movie", movie: movie
  next_screening = @next_screenings[movie.id]
  json.next_screening next_screening && { id: next_screening.id, starts_at: next_screening.starts_at }
end
