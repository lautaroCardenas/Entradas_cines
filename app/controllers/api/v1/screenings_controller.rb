module Api
  module V1
    class ScreeningsController < BaseController
      # GET /api/v1/screenings/:id
      # Devuelve la función con el mapa de asientos (libres y ocupados).
      def show
        @screening = Screening.includes(:movie, hall: [ :cinema, :seats ]).find(params[:id])
        @taken_seat_ids = @screening.taken_seat_ids.to_set
      end
    end
  end
end
