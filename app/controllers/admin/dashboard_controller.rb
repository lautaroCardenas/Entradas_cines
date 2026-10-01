module Admin
  class DashboardController < BaseController
    def show
      @counts = {
        cinemas: Cinema.count,
        halls: Hall.count,
        movies: Movie.now_showing.count,
        upcoming_screenings: Screening.upcoming.count,
        paid_orders: Order.paid.count,
        customers: User.customer.count
      }
      @revenue = Order.paid.sum(:total)
      @next_screenings = Screening.upcoming.chronological.includes(:movie, hall: :cinema).limit(8)
      @latest_orders = Order.order(created_at: :desc).includes(:user, screening: :movie).limit(8)
    end
  end
end
