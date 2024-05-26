class ProductsController < ApplicationController  
  before_action :authenticate!
  before_action :set_store, only: %i[ update destroy index ]
  skip_forgery_protection 
  rescue_from User::InvalidToken, with: :not_authorized

  def index
      products = @store.products.all.map do |product|
        product_attributes = product.attributes
        product_attributes[:image_url] = url_for(product.image) if product.image.attached?
        product_attributes
      end
      render json: { data: products }, status: :ok
  end

  def listing
    if request.format == Mime[:json]
      if @user && @user.admin?
        @products = Product.all
        render json: { message: "Success", data: @products}
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    else
      if !current_user.admin?
        redirect_to root_path, notice: "No permision for you"
      else
        @products = Product.includes(:store)
      end
    end   
  end

  def create
    @store = Store.find(params[:store_id])  # Captura o store_id da URL
    @product = @store.products.new(product_params)
    respond_to do |format|
      if @product.save
        format.html { redirect_to store_products_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: store_products_url(@store, @product) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @product = @store.products.find(params[:id])
    respond_to do |format|
      if (@product.update(product_params))
        format.html { redirect_to store_products_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: store_product_url(@store, @product) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product = @store.products.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to store_products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content } 
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_store
    @store = Store.find(params[:store_id])
  end


  def product_params
    required = params.require(:product).permit(:title, :price, :description, :image, :category, :portion)
  end

  def not_authorized(e)
    render json: {message: "Nope!"}, status: 401
  end
end
