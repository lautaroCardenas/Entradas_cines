class Screening < ApplicationRecord
  CLEANING_MINUTES = 20

  belongs_to :movie
  belongs_to :hall
  has_one :cinema, through: :hall
  has_many :orders, dependent: :restrict_with_error
  has_many :tickets, dependent: :restrict_with_error

  enum :screen_format, { two_d: 0, three_d: 1, imax: 2 }, validate: true
  enum :language, { dubbed: 0, subtitled: 1 }, validate: true

  validates :starts_at, presence: true
  validates :price, numericality: { greater_than: 0 }
  validate :hall_supports_format
  validate :no_overlap_in_hall

  scope :upcoming, -> { where(starts_at: Time.current..) }
  scope :chronological, -> { order(:starts_at) }

  # Hora en que la sala queda libre: duración de la película más el tiempo de limpieza.
  def ends_at
    starts_at + (movie.duration_minutes + CLEANING_MINUTES).minutes
  end

  def taken_seat_ids
    tickets.pluck(:seat_id)
  end

  def available_seats_count
    hall.capacity - tickets.count
  end

  def sold_out?
    available_seats_count <= 0
  end

  def to_s
    "#{movie.title} · #{I18n.l(starts_at, format: :short)} · #{hall}"
  end

  private

  def hall_supports_format
    return if hall.nil? || screen_format.nil?

    errors.add(:screen_format, "no es compatible con el tipo de sala") unless hall.supports?(screen_format)
  end

  def no_overlap_in_hall
    return if hall.nil? || movie.nil? || starts_at.nil?

    candidates = Screening.includes(:movie).where(hall_id: hall_id)
                          .where(starts_at: (starts_at - 12.hours)..ends_at).where.not(id: id)
    overlapping = candidates.find { |other| other.starts_at < ends_at && starts_at < other.ends_at }
    return unless overlapping

    errors.add(:starts_at, "se superpone con otra función en la misma sala (#{I18n.l(overlapping.starts_at, format: :short)})")
  end
end
