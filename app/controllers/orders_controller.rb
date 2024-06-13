class OrdersController < ApplicationController
    skip_forgery_protection only: [:create, :pay, :accept, :ready, :deliver, :dispatched, :cancel]
    before_action :authenticate! 
    before_action :only_buyers!, except: [:index, :pay, :accept, :ready, :deliver, :dispatched, :cancel, :show]
  
    def show
      @order = Order.find(params[:id])
      @store = @order.store
      @buyer = @order.buyer
      @order_items = @order.order_items
    end

    def dispatched
      @order = Order.find(params[:id])
      @order.dispatch!
      if current_user.admin?
        redirect_to orders_path(@order.store, @order)
      else
        render json: { message: "Pedido enviado com sucesso", order: @order }, status: :ok
      end
    end

    def index
      if current_user.admin?
        @orders = Order.all
      else
        @orders = Order.where(buyer: current_user)
      end
    end
  
    def create
      @order = Order.new(order_params) { |o| o.buyer = current_user }
      if @order.save
        render :create, status: :created
      else
        render json: { errors: @order.errors, status: :unprocessable_entity }
      end
    end
  
    def pay
      begin
        if request.get? && current_user.admin?
          @order = Order.find(params[:id])
          render :pay
        else
          order = Order.find(params[:id])
          PaymentJob.perform_later(
            order: order,
            value: payment_params[:value],
            number: payment_params[:number],
            valid: payment_params[:valid],
            cvv: payment_params[:cvv]
          )
          render json: { message: 'Payment processing started' }, status: :ok
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    def accept
      @order = Order.find(params[:id])
      @order.accept!
      if current_user.admin?
        redirect_to orders_path
      else
        render json: { message: "Pedido aceito com sucesso", order: @order }, status: :ok
      end
      rescue StandardError => e
        logger.error "Error accepting order: #{e.message}"
        render json: { error: e.message }, status: :internal_server_error
    end
  
    def ready
      @order = Order.find(params[:id])
      @order.ready!
      if current_user.admin?
        redirect_to orders_path
      else
        render json: { message: "Pedido pronto para envio", order: @order }, status: :ok
      end
    rescue StandardError => e
      logger.error "Error setting order as ready: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  
    def deliver
      @order = Order.find(params[:id])
      @order.deliver!
      if current_user.admin?
        redirect_to orders_path
      else
        render json: { message: "Pedido entregue com sucesso", order: @order }, status: :ok
      end
    rescue StandardError => e
      logger.error "Error delivering order: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  
    def cancel
      @order = Order.find(params[:id])
      @order.cancel!
      if current_user.admin?
        redirect_to orders_path
      else
        render json: { message: "Pedido cancelado com sucesso", order: @order }, status: :ok
      end
    rescue StandardError => e
      logger.error "Error canceling order: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  
    private
  
    def order_params
      params.require(:order).permit(:store_id, order_items_attributes: [:product_id, :amount, :price])
    end
  
    def payment_params
      params.require(:payment).permit(:value, :number, :valid, :cvv)
    end
  end
  
  