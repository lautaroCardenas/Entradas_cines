module Admin
  class CinemasController < BaseController
    before_action :set_cinema, only: %i[show edit update destroy]

    def index
      @cinemas = Cinema.order(:name).includes(:halls)
    end

    def show
      @halls = @cinema.halls.order(:name)
    end

    def new
      @cinema = Cinema.new
    end

    def create
      @cinema = Cinema.new(cinema_params)
      if @cinema.save
        redirect_to admin_cinema_path(@cinema), notice: "Sede creada."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @cinema.update(cinema_params)
        redirect_to admin_cinema_path(@cinema), notice: "Sede actualizada."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      destroy_record(@cinema, admin_cinemas_path)
    end

    private

    def set_cinema
      @cinema = Cinema.find(params[:id])
    end

    def cinema_params
      params.expect(cinema: %i[name address city])
    end
  end
end
