module Admin
  class OrdersController < BaseController
    before_action :set_order, only: %i[show destroy pay cancel]

    def index
      @orders = Order.includes(:user, :tickets, screening: [ :movie, { hall: :cinema } ]).order(created_at: :desc)
      @orders = @orders.where(status: params[:status]) if Order.statuses.key?(params[:status])
      @orders = @orders.where(screening_id: params[:screening_id]) if params[:screening_id].present?
    end

    def show
    end

    # Venta en dos pasos: primero se elige la función; con la función elegida
    # se muestra el mapa de asientos para seleccionar.
    def new
      @order = Order.new(screening_id: params[:screening_id], user_id: params[:user_id])
      load_seat_map if @order.screening
    end

    def create
      @order = Order.new(order_params.except(:seat_ids))
      @order.assign_seats(order_params[:seat_ids])
      if @order.save
        redirect_to admin_order_path(@order), notice: "Compra registrada."
      else
        load_seat_map if @order.screening
        render :new, status: :unprocessable_content
      end
    end

    def pay
      if @order.mark_paid!
        redirect_to admin_order_path(@order), notice: "Compra marcada como pagada."
      else
        redirect_to admin_order_path(@order), alert: "Solo se pueden pagar compras pendientes."
      end
    end

    def cancel
      if @order.cancel!
        redirect_to admin_order_path(@order), notice: "Compra cancelada. Los asientos quedaron liberados."
      else
        redirect_to admin_order_path(@order), alert: "La compra ya estaba cancelada."
      end
    end

    def destroy
      destroy_record(@order, admin_orders_path)
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.expect(order: [ :user_id, :screening_id, :status, seat_ids: [] ])
    end

    def load_seat_map
      @taken_seat_ids = @order.screening.taken_seat_ids
      @seats_by_row = @order.screening.hall.seats.group_by(&:row)
    end
  end
end
