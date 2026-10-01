# Vista previa: http://localhost:3000/rails/mailers/user_mailer/welcome
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome(User.customer.first)
  end
end
