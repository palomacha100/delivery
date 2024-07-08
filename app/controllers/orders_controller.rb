class OrdersController < ApplicationController
    skip_forgery_protection only: [:create, :pay, :accept, :ready, :deliver, :dispatched, 
      :cancel, :new]
    before_action :authenticate! 
    before_action :only_buyers!, except: [:index, :pay, :accept, :ready, :deliver, 
      :dispatched, :cancel, :show, :new, :create]

    def show
      @order = Order.includes(order_items: :product).find(params[:id])
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
      filtered_order_items_attributes = order_params[:order_items_attributes].reject { |item| item[:product_id].blank? || item[:amount].blank? }
      @order = Order.new(order_params.except(:order_items_attributes).merge(order_items_attributes: filtered_order_items_attributes))
      @order.buyer_id = params[:order][:buyer_id]

      Rails.logger.debug "Order Params: #{order_params.inspect}"
      Rails.logger.debug "Filtered Order Items: #{filtered_order_items_attributes.inspect}"
      Rails.logger.debug "Order: #{@order.inspect}"
      Rails.logger.debug "Buyer ID: #{params[:order][:buyer_id]}"
      if @order.save
        Rails.logger.debug "Order Errors: #{@order.errors.full_messages.inspect}"
        redirect_to order_path(@order)
      else
        Rails.logger.debug "Order Errors2: #{@order.errors.full_messages.inspect}"
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def new
      @order = Order.new
      @order.order_items.build
    end

  
    def pay
      begin
        if request.get? && current_user.admin?
          @order = Order.find(params[:id])
          render :pay
        elsif request.put? && current_user.admin?
          order = Order.find(params[:id])
          PaymentJob.perform_later(
            order: order,
            value: payment_params[:value],
            number: payment_params[:number],
            valid: payment_params[:valid],
            cvv: payment_params[:cvv]
          )
          redirect_to orders_path
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
      params.require(:order).permit(:store_id, :buyer_id, order_items_attributes: [:product_id, :amount, :price])
    end
  
    def payment_params
      params.require(:payment).permit(:value, :number, :valid, :cvv)
    end
  end
  
  