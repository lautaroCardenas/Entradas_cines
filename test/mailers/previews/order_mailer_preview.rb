# Vista previa: http://localhost:3000/rails/mailers/order_mailer/confirmation
class OrderMailerPreview < ActionMailer::Preview
  def confirmation
    OrderMailer.confirmation(Order.paid.first || Order.first)
  end
end
