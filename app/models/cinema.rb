class Cinema < ApplicationRecord
  has_many :halls, dependent: :restrict_with_error
  has_many :screenings, through: :halls

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :address, :city, presence: true

  def to_s
    name
  end
end
