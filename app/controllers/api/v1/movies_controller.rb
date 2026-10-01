module Api
  module V1
    class MoviesController < BaseController
      # GET /api/v1/movies?status=coming_soon
      # Por defecto devuelve la cartelera (películas en cartelera).
      def index
        status = Movie.statuses.key?(params[:status]) ? params[:status] : "now_showing"
        @movies = Movie.where(status: status).order(:title).with_attached_poster
      end

      # GET /api/v1/movies/:id?cinema_id=1&date=2026-09-30
      # Incluye las próximas funciones, filtrables por sede y día.
      def show
        @movie = Movie.where.not(status: :archived).find(params[:id])
        @screenings = @movie.screenings.upcoming.chronological.includes(hall: :cinema)
        @screenings = @screenings.joins(:hall).where(halls: { cinema_id: params[:cinema_id] }) if params[:cinema_id].present?
        @screenings = @screenings.where(starts_at: Date.parse(params[:date]).all_day) if params[:date].present?
      rescue Date::Error
        render_error("Fecha inválida, usar formato AAAA-MM-DD", :bad_request)
      end
    end
  end
end
