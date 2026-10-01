class OrderMailer < ApplicationMailer
  # Se envía cuando una compra pasa a estado pagada.
  def confirmation(order)
    @order = order
    @screening = order.screening
    mail subject: "Tus entradas para #{@screening.movie.title}", to: order.user.email_address
  end
end
