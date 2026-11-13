module Api
  module V1
    class MoviesController < BaseController
      # GET /api/v1/movies?status=coming_soon&date=2026-10-28&cinema_id=1
      # Por defecto devuelve la cartelera (películas en cartelera). Con `date` y/o
      # `cinema_id` devuelve solo las que tienen funciones próximas ese día / en esa sede.
      def index
        status = Movie.statuses.key?(params[:status]) ? params[:status] : "now_showing"
        @movies = Movie.where(status: status).order(:title).with_attached_poster
        if params[:date].present? || params[:cinema_id].present?
          @movies = @movies.where(id: filtered_screenings(Screening.all).select(:movie_id))
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

      def filtered_screenings(scope)
        scope = scope.upcoming.chronological
        scope = scope.joins(:hall).where(halls: { cinema_id: params[:cinema_id] }) if params[:cinema_id].present?
        scope = scope.where(starts_at: Date.parse(params[:date]).all_day) if params[:date].present?
        scope
      end
    end
  end
end
