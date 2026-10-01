require "test_helper"

class AdminBackofficeTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @customer = users(:two)
    @cinema = Cinema.create!(name: "Centro", address: "Calle 1", city: "Mendoza")
    @hall = Hall.create!(cinema: @cinema, name: "Sala 1", hall_type: :imax, rows_count: 3, seats_per_row: 4)
    @movie = Movie.create!(title: "Órbita baja", genre: "Ciencia ficción", duration_minutes: 132, rating: "+13")
    @screening = Screening.create!(movie: @movie, hall: @hall, starts_at: 1.day.from_now, screen_format: :imax, price: 1000)
    @order = Order.new(user: @customer, screening: @screening)
    @order.assign_seats(@hall.seats.first(2).map(&:id))
    @order.save!
  end

  test "requires login" do
    get admin_root_path
    assert_redirected_to new_session_path
  end

  test "customers cannot access the back-office" do
    sign_in_as(@customer)
    get admin_movies_path
    assert_redirected_to new_session_path
  end

  test "admin can browse every section" do
    sign_in_as(@admin)
    [
      admin_root_path,
      admin_cinemas_path, admin_cinema_path(@cinema), new_admin_cinema_path, edit_admin_cinema_path(@cinema),
      admin_halls_path, admin_hall_path(@hall), new_admin_hall_path, edit_admin_hall_path(@hall),
      admin_movies_path, admin_movie_path(@movie), new_admin_movie_path, edit_admin_movie_path(@movie),
      admin_screenings_path, admin_screening_path(@screening), new_admin_screening_path, edit_admin_screening_path(@screening),
      admin_orders_path, admin_order_path(@order), new_admin_order_path, new_admin_order_path(screening_id: @screening.id),
      admin_users_path, admin_user_path(@customer), new_admin_user_path, edit_admin_user_path(@customer)
    ].each do |path|
      get path
      assert_response :success, "Falló #{path}"
    end
  end

  test "admin sells tickets and cancels the order" do
    sign_in_as(@admin)
    seat = @hall.seats.last

    assert_difference -> { Ticket.count }, 1 do
      post admin_orders_path, params: { order: { user_id: @customer.id, screening_id: @screening.id, status: "pending", seat_ids: [ seat.id ] } }
    end
    order = Order.last
    assert_redirected_to admin_order_path(order)
    assert_equal BigDecimal("1100"), order.total

    patch cancel_admin_order_path(order)
    assert order.reload.cancelled?
    assert_not_includes @screening.taken_seat_ids, seat.id
  end

  test "selling an occupied seat fails" do
    sign_in_as(@admin)
    taken = @order.tickets.first.seat_id

    assert_no_difference -> { Order.count } do
      post admin_orders_path, params: { order: { user_id: @customer.id, screening_id: @screening.id, seat_ids: [ taken ] } }
    end
    assert_response :unprocessable_content
  end

  test "hall with sold tickets cannot be deleted" do
    sign_in_as(@admin)
    assert_no_difference -> { Hall.count } do
      delete admin_hall_path(@hall)
    end
  end
end
