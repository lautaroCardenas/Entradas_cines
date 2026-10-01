class UserMailer < ApplicationMailer
  # Se envía cuando un cliente se registra desde la API.
  def welcome(user)
    @user = user
    mail subject: "¡Bienvenido/a a Sala Norte!", to: user.email_address
  end
end
