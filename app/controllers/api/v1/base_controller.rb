module Api
  module V1
    # Base de la API pública: responde siempre JSON y autentica con un token
    # enviado en el header "Authorization: Bearer <token>".
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActionController::ParameterMissing, with: :bad_request

      private

      def current_session
        @current_session ||= authenticate_with_http_token do |token, _options|
          Session.includes(:user).find_by(token: token)
        end
      end

      def current_user
        current_session&.user
      end

      def authenticate_user!
        render_error("No autenticado. Enviá el header Authorization: Bearer <token>", :unauthorized) unless current_user
      end

      def render_error(message, status, details: nil)
        body = { error: message }
        body[:details] = details if details
        render json: body, status: status
      end

      def render_validation_errors(record)
        render_error("No se pudo procesar la solicitud", :unprocessable_content, details: record.errors.full_messages)
      end

      def not_found
        render_error("Recurso no encontrado", :not_found)
      end

      def bad_request(exception)
        render_error(exception.message, :bad_request)
      end
    end
  end
end
