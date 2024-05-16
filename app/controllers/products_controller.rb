class ProductsController < ApplicationController
  before_action :authenticate!
  before_action :set_product, only: %i[ show edit update destroy ]
  def listing
    if current_user.admin?
      redirect_to root_path, notice: "No permission for you"
    end
    @products = Product.includes(:store)
  end

  private
  def product_params
    required = params.require(:product),
    permit(:title, :price, :description, :image, :category, :portion)
  end

  def set_product
    @product = Product.find(params[:id])
  end



end
