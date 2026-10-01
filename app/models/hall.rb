class Hall < ApplicationRecord
  ROW_LETTERS = ("A".."Z").to_a.freeze

  belongs_to :cinema
  has_many :seats, -> { order(:row, :number) }, dependent: :destroy
  has_many :screenings, dependent: :restrict_with_error

  enum :hall_type, { standard: 0, three_d: 1, imax: 2 }, validate: true

  validates :name, presence: true, uniqueness: { scope: :cinema_id }
  validates :rows_count, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: ROW_LETTERS.size }
  validates :seats_per_row, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 30 }
  validate :layout_locked_when_tickets_sold, on: :update

  after_save :generate_seats, if: -> { saved_change_to_rows_count? || saved_change_to_seats_per_row? }

  def capacity
    rows_count * seats_per_row
  end

  # Una sala IMAX puede proyectar cualquier formato; una 3D, 2D y 3D; una estándar, solo 2D.
  def supports?(screen_format)
    case screen_format.to_s
    when "imax" then imax?
    when "three_d" then three_d? || imax?
    else true
    end
  end

  def to_s
    "#{cinema.name} · #{name}"
  end

  private

  def generate_seats
    seats.delete_all
    now = Time.current
    rows = ROW_LETTERS.first(rows_count).flat_map do |row|
      (1..seats_per_row).map do |number|
        { hall_id: id, row: row, number: number, accessible: false, created_at: now, updated_at: now }
      end
    end
    Seat.insert_all(rows)
    seats.reset
  end

  def layout_locked_when_tickets_sold
    return unless rows_count_changed? || seats_per_row_changed?
    return unless Ticket.joins(:seat).where(seats: { hall_id: id }).exists?

    errors.add(:base, "No se puede cambiar la distribución de una sala que ya tiene entradas vendidas")
  end
end
