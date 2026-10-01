module Api
  module V1
    # Compras del usuario autenticado ("Mis entradas").
    class OrdersController < BaseController
      before_action :authenticate_user!
      before_action :set_order, only: %i[show pay cancel]

      # GET /api/v1/orders
      def index
        @orders = current_user.orders.includes(tickets: :seat, screening: [ :movie, { hall: :cinema } ])
                              .order(created_at: :desc)
      end

      # GET /api/v1/orders/:id
      def show
      end

      # POST /api/v1/orders  { "order": { "screening_id": 1, "seat_ids": [10, 11] } }
      def create
        order_params = params.expect(order: [ :screening_id, seat_ids: [] ])
        screening = Screening.upcoming.find(order_params[:screening_id])

        @order = current_user.orders.build(screening: screening)
        @order.assign_seats(order_params[:seat_ids])
        if @order.save
          render :show, status: :created
        else
          render_validation_errors(@order)
        end
      end

      # PATCH /api/v1/orders/:id/pay  (simula el pago de la compra)
      def pay
        if @order.mark_paid!
          render :show
        else
          render_error("Solo se pueden pagar compras pendientes", :unprocessable_content)
        end
      end

      # PATCH /api/v1/orders/:id/cancel
      def cancel
        if @order.cancel!
          render :show
        else
          render_error("La compra ya estaba cancelada", :unprocessable_content)
        end
      end

      private

      # Solo se buscan compras del usuario autenticado: pedir la de otro devuelve 404.
      def set_order
        @order = current_user.orders.find(params[:id])
      end
    end
  end
end
