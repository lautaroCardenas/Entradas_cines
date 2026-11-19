module Api
  module V1
    class MoviesController < BaseController
      # GET /api/v1/movies?status=coming_soon&date=2026-10-28&cinema_id=1
      # Por defecto devuelve la cartelera (películas en cartelera). Con `date` y/o
      # `cinema_id` devuelve solo las que tienen funciones próximas ese día / en esa sede.
      # Cada película incluye su próxima función (`next_screening`) y la lista se ordena
      # por esa función: primero las que empiezan antes; las que no tienen, al final.
      def index
        status = Movie.statuses.key?(params[:status]) ? params[:status] : "now_showing"
        movies = Movie.where(status: status).with_attached_poster.to_a
        @next_screenings = next_screenings_by_movie(movies.map(&:id))
        movies.select! { |movie| @next_screenings.key?(movie.id) } if params[:date].present? || params[:cinema_id].present?
        @movies = movies.sort_by do |movie|
          next_screening = @next_screenings[movie.id]
          next_screening ? [ 0, next_screening.starts_at.to_i, movie.title ] : [ 1, 0, movie.title ]
        end
      rescue Date::Error
        render_error("Fecha inválida, usar formato AAAA-MM-DD", :bad_request)
      end

      # GET /api/v1/movies/:id?cinema_id=1&date=2026-10-28
      # Incluye las próximas funciones, filtrables por sede y día.
      def show
        @movie = Movie.where.not(status: :archived).find(params[:id])
        @screenings = filtered_screenings(@movie.screenings).includes(hall: :cinema)
      rescue Date::Error
        render_error("Fecha inválida, usar formato AAAA-MM-DD", :bad_request)
      end

      private

      # Primera función próxima de cada película (con los filtros de día y sede), en una sola consulta.
      def next_screenings_by_movie(movie_ids)
        filtered_screenings(Screening.where(movie_id: movie_ids))
          .select("screenings.id", "screenings.movie_id", "screenings.starts_at")
          .each_with_object({}) { |screening, firsts| firsts[screening.movie_id] ||= screening }
      end

      def filtered_screenings(scope)
        scope = scope.upcoming.chronological
        scope = scope.joins(:hall).where(halls: { cinema_id: params[:cinema_id] }) if params[:cinema_id].present?
        scope = scope.where(starts_at: Date.parse(params[:date]).all_day) if params[:date].present?
        scope
      end
    end
  end
end
