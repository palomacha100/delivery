class ProductsController < ApplicationController  
  before_action :authenticate!
  before_action :set_locale!
  before_action :set_store, only: %i[ edit update destroy index show ]
  skip_forgery_protection 
  rescue_from User::InvalidToken, with: :not_authorized
  before_action :set_product, only: %i[ edit show ]

  def index
    respond_to do |format|
      format.json do
        if buyer?
          page = params.fetch(:page, 1)
          @products = Product.includes(:image_attachment).
          where(store_id: params[:store_id]).
          order(:title)
          @products = @products.page(page)
        else 
          products = @store.products.all.map do |product|
            product_attributes = product.attributes
            product_attributes[:image_url] = url_for(product.image) if product.image.attached?
            product_attributes
         
          end
          render json: { data: products }, status: :ok
        end
      end
    end
  end

  def active_product 
    @store = Store.find(params[:store_id])
    if @store.user.discarded? || @store.discarded?
      flash[:notice] = "Unprocessable entity."
      render :show, status: :unprocessable_entity
    else
      @product = @store.products.find(params[:id]).undiscard
      redirect_to listing_path, notice: 'Product reactivated successfully'
    end
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

  def edit
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

  def show
    @product = @store.products.find_by(id: params[:id])
  end

  def destroy
    @product = @store.products.find(params[:id])
    @product.discard!

    respond_to do |format|
      format.html { redirect_to store_products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content } 
    end
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end


  def product_params
    required = params.require(:product).permit(:title, :price, :description, :image, :category, :portion)
  end

  def not_authorized(e)
    render json: {message: "Nope!"}, status: 401
  end

  def set_product
    @product =  @store.products.find_by(id: params[:id])
    if @product.nil?
      respond_to do |format|
        format.html { redirect_to store_url(@store), alert: "Product not found or has been discarded." }
        format.json { render json: { error: "Product not found or has been discarded" }, status: :not_found }
      end
    end
  end
end
