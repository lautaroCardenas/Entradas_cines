json.extract! movie, :id, :title, :genre, :duration_minutes, :rating, :release_date
json.duration movie.duration_label
json.status movie.status
json.poster_url movie.poster.attached? ? rails_blob_url(movie.poster) : nil
