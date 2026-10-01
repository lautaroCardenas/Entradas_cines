module Admin
  class HallsController < BaseController
    before_action :set_hall, only: %i[show edit update destroy]

    def index
      @halls = Hall.includes(:cinema).order("cinemas.name", :name).references(:cinema)
      @halls = @halls.where(cinema_id: params[:cinema_id]) if params[:cinema_id].present?
    end

    def show
      @seats_by_row = @hall.seats.group_by(&:row)
    end

    def new
      @hall = Hall.new(cinema_id: params[:cinema_id], rows_count: 8, seats_per_row: 12)
    end

    def create
      @hall = Hall.new(hall_params)
      if @hall.save
        redirect_to admin_hall_path(@hall), notice: "Sala creada con #{@hall.capacity} asientos."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @hall.update(hall_params)
        redirect_to admin_hall_path(@hall), notice: "Sala actualizada."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      destroy_record(@hall, admin_halls_path)
    end

    private

    def set_hall
      @hall = Hall.find(params[:id])
    end

    def hall_params
      params.expect(hall: %i[cinema_id name hall_type rows_count seats_per_row])
    end
  end
end
