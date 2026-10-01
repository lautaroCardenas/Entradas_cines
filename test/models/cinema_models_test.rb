require "test_helper"

class CinemaModelsTest < ActiveSupport::TestCase
  setup do
    @cinema = Cinema.create!(name: "Centro", address: "Calle 1", city: "Mendoza")
    @hall = Hall.create!(cinema: @cinema, name: "Sala 1", hall_type: :three_d, rows_count: 3, seats_per_row: 4)
    @movie = Movie.create!(title: "Nueve lunas", genre: "Animación", duration_minutes: 95, rating: "ATP")
    @screening = Screening.create!(movie: @movie, hall: @hall, starts_at: 1.day.from_now.change(hour: 15), price: 1000)
  end

  test "user validates presence, email format and password length" do
    user = User.new(name: "", email_address: "no-es-mail", password: "corta")
    assert_not user.valid?
    assert user.errors.of_kind?(:name, :blank)
    assert user.errors.of_kind?(:email_address, :invalid)
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "movie requires a valid rating and a positive duration" do
    movie = Movie.new(title: "X", genre: "Drama", duration_minutes: 0, rating: "+99")
    assert_not movie.valid?
    assert movie.errors.of_kind?(:duration_minutes, :greater_than)
    assert movie.errors.of_kind?(:rating, :inclusion)
  end

  test "creating a hall generates its seats" do
    assert_equal 12, @hall.seats.count
    assert_equal %w[A1 A2 A3 A4], @hall.seats.where(row: "A").map(&:label)
  end

  test "hall layout cannot change once tickets are sold" do
    buy([ @hall.seats.first.id ])
    @hall.rows_count = 5
    assert_not @hall.valid?
  end

  test "screenings cannot overlap in the same hall" do
    overlapping = Screening.new(movie: @movie, hall: @hall, starts_at: @screening.starts_at + 1.hour, price: 1000)
    assert_not overlapping.valid?
    assert overlapping.errors.key?(:starts_at)

    after_cleaning = Screening.new(movie: @movie, hall: @hall, starts_at: @screening.ends_at, price: 1000)
    assert after_cleaning.valid?
  end

  test "screening format must be supported by the hall" do
    imax = Screening.new(movie: @movie, hall: @hall, starts_at: 3.days.from_now, screen_format: :imax, price: 1000)
    assert_not imax.valid?
    assert imax.errors.key?(:screen_format)
  end

  test "order calculates totals with service fee" do
    order = buy(@hall.seats.first(3).map(&:id))
    assert_equal BigDecimal("300"), order.service_fee
    assert_equal BigDecimal("3300"), order.total
    assert_equal 9, @screening.available_seats_count
  end

  test "a seat cannot be sold twice for the same screening" do
    seat_id = @hall.seats.first.id
    buy([ seat_id ])

    order = Order.new(user: users(:two), screening: @screening)
    order.assign_seats([ seat_id ])
    assert_not order.save
  end

  test "an order needs at least one seat and at most the limit" do
    empty = Order.new(user: users(:two), screening: @screening)
    empty.assign_seats([])
    assert_not empty.valid?

    big_hall = Hall.create!(cinema: @cinema, name: "Grande", rows_count: 2, seats_per_row: 10)
    screening = Screening.create!(movie: @movie, hall: big_hall, starts_at: 2.days.from_now, price: 1000)
    too_many = Order.new(user: users(:two), screening: screening)
    too_many.assign_seats(big_hall.seats.first(Order::MAX_TICKETS + 1).map(&:id))
    assert_not too_many.valid?
  end

  test "cancelling an order releases its seats" do
    order = buy(@hall.seats.first(2).map(&:id))
    order.cancel!
    assert order.cancelled?
    assert_empty @screening.taken_seat_ids
  end

  private

  def buy(seat_ids)
    order = Order.new(user: users(:two), screening: @screening)
    order.assign_seats(seat_ids)
    order.save!
    order
  end
end
