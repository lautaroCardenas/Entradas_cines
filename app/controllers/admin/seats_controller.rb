module Admin
  # Permite marcar/desmarcar un asiento como apto para movilidad reducida.
  class SeatsController < BaseController
    def update
      hall = Hall.find(params[:hall_id])
      seat = hall.seats.find(params[:id])
      seat.update!(accessible: !seat.accessible)
      redirect_to admin_hall_path(hall), notice: "Asiento #{seat.label} actualizado."
    end
  end
end
