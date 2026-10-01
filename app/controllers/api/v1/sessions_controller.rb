module Api
  module V1
    class SessionsController < BaseController
      before_action :authenticate_user!, only: :destroy
      rate_limit to: 10, within: 3.minutes, only: :create,
                 with: -> { render_error("Demasiados intentos. Probá de nuevo en unos minutos.", :too_many_requests) }

      # POST /api/v1/login
      def create
        user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
        if user
          session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
          render json: { token: session.token, user: user_json(user) }, status: :created
        else
          render_error("Correo o contraseña incorrectos", :unauthorized)
        end
      end

      # DELETE /api/v1/logout
      def destroy
        current_session.destroy
        head :no_content
      end

      private

      def user_json(user)
        { id: user.id, name: user.name, email_address: user.email_address }
      end
    end
  end
end
