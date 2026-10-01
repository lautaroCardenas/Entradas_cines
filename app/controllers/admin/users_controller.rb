module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]

    def index
      @users = User.order(:name)
      @users = @users.where(role: params[:role]) if User.roles.key?(params[:role])
    end

    def show
      @orders = @user.orders.includes(screening: :movie).order(created_at: :desc)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_user_path(@user), notice: "Usuario creado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      attributes = user_params
      attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?

      if @user == Current.user && attributes[:role].present? && attributes[:role] != "admin"
        @user.errors.add(:role, "no podés quitarte el rol de administrador a vos mismo")
        render :edit, status: :unprocessable_content
      elsif @user.update(attributes)
        redirect_to admin_user_path(@user), notice: "Usuario actualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @user == Current.user
        redirect_to admin_user_path(@user), alert: "No podés eliminar tu propio usuario."
      else
        destroy_record(@user, admin_users_path)
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: %i[name email_address role password password_confirmation])
    end
  end
end
