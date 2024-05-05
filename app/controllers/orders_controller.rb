class OrdersController < ApplicationController
    skip_forgery_protection only: [:create]
    before_action :authenticate!, :only_buyers!

    def create
        @order = Order.new(order_params) { |o| o.buyer = current_user }
        puts @order.inspect
        if !@order.save
            render json: {errors: @order.errors, status: unprocessable_entity}
        end
    end

    private

    def order_params
        params.require(:order).permit([:store_id])
    end
end