class Ticket < ApplicationRecord
  belongs_to :order
  belongs_to :screening
  belongs_to :seat

  validates :price, numericality: { greater_than: 0 }
  validates :seat_id, uniqueness: { scope: :screening_id, message: "ya está ocupado para esta función" }
  validates :code, presence: true, uniqueness: true
  validate :seat_belongs_to_screening_hall

  before_validation :generate_code, on: :create

  private

  def generate_code
    self.code ||= SecureRandom.alphanumeric(10).upcase
  end

  def seat_belongs_to_screening_hall
    return if seat.nil? || screening.nil?

    errors.add(:seat, "no pertenece a la sala de la función") if seat.hall_id != screening.hall_id
  end
end
