class OrdersController < ApplicationController
    skip_forgery_protection only: [:create, :pay, :accept, :prepare, :ready, :deliver, :cancel]
    before_action :authenticate! 
    before_action :only_buyers!, except: [:index, :pay, :accept, :prepare, :ready, :deliver, :cancel]
  
    def dispatched
      @order = Order.find(params[:id])
      @order.dispatch!
      render json: { message: "Pedido enviado com sucesso", order: @order }, status: :ok
    end

    def index
      @orders = Order.where(buyer: current_user)
    end
  
    def create
      @order = Order.new(order_params) { |o| o.buyer = current_user }
      puts @order.inspect
      if @order.save
        render :create, status: :created
      else
        render json: { errors: @order.errors, status: :unprocessable_entity }
      end
    end
  
    def pay
      order = Order.find(params[:id])
      PaymentJob.perform_later(
        order: order,
        value: payment_params[:value],
        number: payment_params[:number],
        valid: payment_params[:valid],
        cvv: payment_params[:cvv]
      )
      render json: { message: 'Payment processing started' }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  
    def accept
      @order = Order.find(params[:id])
      @order.accept!
      render json: { message: "Pedido aceito com sucesso", order: @order }, status: :ok
    rescue StandardError => e
      logger.error "Error accepting order: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  
    def prepare
      @order = Order.find(params[:id])
      @order.prepare!
      render json: { message: "Pedido preparado com sucesso", order: @order }, status: :ok
    rescue StandardError => e
      logger.error "Error preparing order: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  
    def ready
      @order = Order.find(params[:id])
      @order.ready!
      render json: { message: "Pedido pronto para envio", order: @order }, status: :ok
    rescue StandardError => e
      logger.error "Error setting order as ready: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  

  
    def deliver
      @order = Order.find(params[:id])
      @order.deliver!
      render json: { message: "Pedido entregue com sucesso", order: @order }, status: :ok
    rescue StandardError => e
      logger.error "Error delivering order: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  
    def cancel
      @order = Order.find(params[:id])
      @order.cancel!
      render json: { message: "Pedido cancelado com sucesso", order: @order }, status: :ok
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
  
  