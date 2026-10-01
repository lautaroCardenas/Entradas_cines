module Admin
  # Controlador base del back-office: exige sesión iniciada (Authentication)
  # y además que el usuario tenga rol de administrador.
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin

    private

    def require_admin
      return if Current.user&.admin?

      terminate_session
      redirect_to new_session_path, alert: "Tu cuenta no tiene acceso al back-office."
    end

    def destroy_record(record, redirect_path)
      if record.destroy
        redirect_to redirect_path, notice: "#{record.model_name.human} eliminado/a.", status: :see_other
      else
        redirect_back_or_to redirect_path, alert: record.errors.full_messages.to_sentence, status: :see_other
      end
    end
  end
end
