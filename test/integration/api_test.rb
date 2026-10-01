require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @customer = users(:two)
    cinema = Cinema.create!(name: "Centro", address: "Calle 1", city: "Mendoza")
    @hall = Hall.create!(cinema: cinema, name: "Sala 1", rows_count: 2, seats_per_row: 3)
    @movie = Movie.create!(title: "Casa de verano", genre: "Comedia", duration_minutes: 101, rating: "ATP")
    @screening = Screening.create!(movie: @movie, hall: @hall, starts_at: 1.day.from_now, price: 1000)
  end

  test "login returns a token and rejects wrong passwords" do
    post api_v1_login_path, params: { email_address: @customer.email_address, password: "password" }, as: :json
    assert_response :created
    assert response.parsed_body["token"].present?

    post api_v1_login_path, params: { email_address: @customer.email_address, password: "mala" }, as: :json
    assert_response :unauthorized
  end

  test "public endpoints do not require a token" do
    get api_v1_movies_path, as: :json
    assert_response :success
    assert_equal [ "Casa de verano" ], response.parsed_body.map { |m| m["title"] }

    get api_v1_screening_path(@screening), as: :json
    assert_response :success
    assert_equal 6, response.parsed_body["seats"].size
  end

  test "protected endpoints require a token" do
    get api_v1_profile_path, as: :json
    assert_response :unauthorized

    get api_v1_profile_path, headers: auth_headers, as: :json
    assert_response :success
    assert_equal @customer.email_address, response.parsed_body["email_address"]
  end

  test "customer buys, pays and gets a confirmation email" do
    seat_ids = @hall.seats.first(2).map(&:id)

    post api_v1_orders_path, params: { order: { screening_id: @screening.id, seat_ids: seat_ids } }, headers: auth_headers, as: :json
    assert_response :created
    body = response.parsed_body
    assert_equal "pending", body["status"]
    assert_equal "2200.0", body["total"]

    assert_enqueued_email_with OrderMailer, :confirmation, args: [ Order.find(body["id"]) ] do
      patch pay_api_v1_order_path(body["id"]), headers: auth_headers, as: :json
    end
    assert_equal "paid", response.parsed_body["status"]
  end

  test "buying an occupied seat returns 422" do
    seat = @hall.seats.first
    order = Order.new(user: users(:one), screening: @screening)
    order.assign_seats([ seat.id ])
    order.save!

    post api_v1_orders_path, params: { order: { screening_id: @screening.id, seat_ids: [ seat.id ] } }, headers: auth_headers, as: :json
    assert_response :unprocessable_content
    assert_includes response.parsed_body["details"].join, "ocupados"
  end

  test "a customer cannot see another user's order" do
    order = Order.new(user: users(:one), screening: @screening)
    order.assign_seats([ @hall.seats.first.id ])
    order.save!

    get api_v1_order_path(order), headers: auth_headers, as: :json
    assert_response :not_found
  end

  private

  def auth_headers
    token = @customer.sessions.create!.token
    { "Authorization" => "Bearer #{token}" }
  end
end
