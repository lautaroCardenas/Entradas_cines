class Session < ApplicationRecord
  belongs_to :user

  # Token para autenticar al usuario final contra la API (header Authorization: Bearer <token>).
  # Las sesiones del back-office usan cookie y también reciben uno, pero no lo exponen.
  has_secure_token :token
end
