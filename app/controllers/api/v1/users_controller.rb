module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_user!, only: :profile

      # POST /api/v1/users  (registro de un cliente nuevo)
      def create
        @user = User.new(params.expect(user: %i[name email_address password password_confirmation]))
        @user.role = :customer
        if @user.save
          session = @user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
          UserMailer.welcome(@user).deliver_later
          @token = session.token
          render :show, status: :created
        else
          render_validation_errors(@user)
        end
      end

      # GET /api/v1/profile
      def profile
        @user = current_user
        render :show
      end
    end
  end
end
