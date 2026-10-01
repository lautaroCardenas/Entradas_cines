module Admin
  class ScreeningsController < BaseController
    before_action :set_screening, only: %i[show edit update destroy]

    def index
      @screenings = Screening.includes(:movie, hall: :cinema).chronological
      @screenings = @screenings.where(movie_id: params[:movie_id]) if params[:movie_id].present?
      @screenings = @screenings.joins(:hall).where(halls: { cinema_id: params[:cinema_id] }) if params[:cinema_id].present?
      if params[:date].present?
        day = Date.parse(params[:date])
        @screenings = @screenings.where(starts_at: day.all_day)
      elsif params[:all].blank?
        @screenings = @screenings.upcoming
      end
    rescue Date::Error
      redirect_to admin_screenings_path, alert: "Fecha inválida."
    end

    def show
      @taken_seat_ids = @screening.taken_seat_ids
      @seats_by_row = @screening.hall.seats.group_by(&:row)
      @orders = @screening.orders.includes(:user, tickets: :seat).order(created_at: :desc)
    end

    def new
      @screening = Screening.new(movie_id: params[:movie_id], price: 5000)
    end

    def create
      @screening = Screening.new(screening_params)
      if @screening.save
        redirect_to admin_screening_path(@screening), notice: "Función creada."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @screening.update(screening_params)
        redirect_to admin_screening_path(@screening), notice: "Función actualizada."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      destroy_record(@screening, admin_screenings_path)
    end

    private

    def set_screening
      @screening = Screening.find(params[:id])
    end

    def screening_params
      params.expect(screening: %i[movie_id hall_id starts_at screen_format language price])
    end
  end
end
