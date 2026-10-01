class Seat < ApplicationRecord
  belongs_to :hall
  has_many :tickets, dependent: :restrict_with_error

  validates :row, presence: true
  validates :number, numericality: { only_integer: true, greater_than: 0 }
  validates :number, uniqueness: { scope: [ :hall_id, :row ] }

  def label
    "#{row}#{number}"
  end
end
