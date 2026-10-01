class Movie < ApplicationRecord
  RATINGS = %w[ATP +13 +16 +18].freeze
  POSTER_TYPES = %w[image/jpeg image/png image/webp].freeze

  has_many :screenings, dependent: :restrict_with_error
  has_one_attached :poster

  enum :status, { now_showing: 0, coming_soon: 1, archived: 2 }, validate: true

  validates :title, presence: true, length: { maximum: 150 }
  validates :genre, presence: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0, less_than: 600 }
  validates :rating, inclusion: { in: RATINGS }
  validate :poster_format

  def duration_label
    "#{duration_minutes / 60} h #{(duration_minutes % 60).to_s.rjust(2, '0')} min"
  end

  def to_s
    title
  end

  private

  def poster_format
    return unless poster.attached?

    errors.add(:poster, "debe ser JPG, PNG o WEBP") unless POSTER_TYPES.include?(poster.content_type)
    errors.add(:poster, "no puede superar los 5 MB") if poster.byte_size > 5.megabytes
  end
end
