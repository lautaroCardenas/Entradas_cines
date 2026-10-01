class Order < ApplicationRecord
  SERVICE_FEE_RATE = BigDecimal("0.10")
  MAX_TICKETS = 10

  belongs_to :user
  belongs_to :screening
  has_many :tickets, dependent: :destroy

  enum :status, { pending: 0, paid: 1, cancelled: 2 }, validate: true

  validate :seat_selection_errors
  validate :has_tickets, on: :create
  validate :tickets_limit
  validate :not_cancelled_on_create, on: :create

  before_validation :calculate_totals, on: :create
  after_commit :send_confirmation_email, on: %i[create update], if: -> { saved_change_to_status? && paid? }

  # Construye las entradas para los asientos elegidos. Los asientos deben
  # pertenecer a la sala de la función y no estar ocupados.
  def assign_seats(seat_ids)
    @seat_errors = []
    return if screening.nil?

    ids = Array(seat_ids).compact_blank.map(&:to_i).uniq
    seats = screening.hall.seats.where(id: ids).to_a
    @seat_errors << "Algunos asientos no pertenecen a la sala" if seats.size != ids.size

    taken = screening.taken_seat_ids & ids
    if taken.any?
      labels = Seat.where(id: taken).map(&:label).join(", ")
      @seat_errors << "Los asientos #{labels} ya están ocupados"
    end

    seats.reject { |seat| taken.include?(seat.id) }.each do |seat|
      tickets.build(seat: seat, screening: screening, price: screening.price)
    end
  end

  def subtotal
    tickets.sum(&:price)
  end

  def seat_labels
    tickets.map { |t| t.seat.label }.sort.join(", ")
  end

  def mark_paid!
    return false unless pending?

    paid!
  end

  # Cancela la compra y libera los asientos para que puedan volver a venderse.
  def cancel!
    return false if cancelled?

    transaction do
      tickets.destroy_all
      cancelled!
    end
  end

  private

  def calculate_totals
    self.service_fee = (subtotal * SERVICE_FEE_RATE).round(2)
    self.total = subtotal + service_fee
  end

  def send_confirmation_email
    OrderMailer.confirmation(self).deliver_later
  end

  def seat_selection_errors
    Array(@seat_errors).each { |message| errors.add(:base, message) }
  end

  def has_tickets
    errors.add(:base, "Debe seleccionar al menos un asiento") if tickets.empty? && @seat_errors.blank?
  end

  def not_cancelled_on_create
    errors.add(:status, "no puede ser cancelada al crear la compra") if cancelled?
  end

  def tickets_limit
    errors.add(:base, "No se pueden comprar más de #{MAX_TICKETS} entradas por compra") if tickets.size > MAX_TICKETS
  end
end
