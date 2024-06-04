class OrdersController < ApplicationController
    skip_forgery_protection only: [:create]
    before_action :authenticate!, :only_buyers!
    before_action :set_order, only: [:show, :update, :destroy, 
    :pay, :confirm_payment, :send_to_seller, :accept, :prepare, 
    :dispatch, :deliver, :complete, :cancel]

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

    private

    def order_params
        params.require(:order).permit(:store_id, order_items_attributes: [ :product_id, :amount, :price])
      end
end