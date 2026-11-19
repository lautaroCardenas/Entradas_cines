json.extract! movie, :id, :title, :genre, :duration_minutes, :rating, :release_date, :synopsis
json.duration movie.duration_label
json.status movie.status
json.poster_url movie.poster.attached? ? rails_blob_url(movie.poster) : nil
