class OrdersController < ApplicationController
    skip_forgery_protection only: [:create, :pay]
    before_action :authenticate!, :only_buyers!
    
    def index
        @orders = Order.where(buyer: current_user)    
    end

    def create
        @order = Order.new(order_params) { |o| o.buyer = current_user }
        puts @order.inspect
        if @order.save
            render :create, status: :created
        else
            render json: {errors: @order.errors, status: :unprocessable_entity}
        end
    end

    def pay
        order = Order.find(params[:id])
        PaymentJob.perform_later(order: order, 
        value: payment_params[:value],number: payment_params[:number],valid: payment_params[:valid],cvv: payment_params[:cvv])
        render json: { message: 'Payment processing started' }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

    private

    def order_params
        params.require(:order).permit(:store_id, order_items_attributes: 
        [ :product_id, :amount, :price])
    end

    def payment_params
        params.require(:payment).permit(:value, :number, :valid, :cvv)
    end

end