class StoresController < ApplicationController
  include ActionController::Live
  skip_forgery_protection only: %i[create update destroy]
  before_action :authenticate!
  before_action :set_store, only: %i[show edit update destroy]
  rescue_from User::InvalidToken, with: :not_authorized

  # GET /stores or /stores.json
  def index
    respond_to do |format|
      format.json do
        page = params.fetch(:page, 1)
        
        if params[:query].present?
          @stores = Store.where("name LIKE ?", "%#{params[:query]}%").page(page)
        else
          if current_user.admin?
            @stores = Store.order(:name).page(page)
          elsif current_user.buyer?
            @stores = Store.kept.where(active: true).includes(image_attachment: :blob).page(page)
          else
            @stores = Store.kept.where(user: current_user).includes(image_attachment: :blob).page(page)
          end
        end
  
        stores_data = @stores.map do |store|
          store_attributes = store.attributes
          store_attributes[:image_url] = url_for(store.image) if store.image.attached?
          store_attributes
        end
  
        render json: {
          data: stores_data,
          meta: {
            current_page: @stores.current_page,
            total_pages: @stores.total_pages,
            total_count: @stores.total_count
          }
        }, status: :ok
      end
      format.html do
        if !current_user.admin?
          redirect_to root_path, notice: "No permission for you"
        else
          page = params.fetch(:page, 1)
          @stores = Store.order(:name).page(page).per(10) # Paginação com 10 produtos por página
        end
      end
    end
  end

  # GET /stores/1 or /stores/1.json
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new
    if current_user.admin? 
      @sellers = User.where(role: :seller)
    end
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores or /stores.json
  def create
    @store = Store.new(store_params)
    if !current_user.admin?
      @store.user = current_user
    end

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def active_store
    @store = Store.find(params[:id])
    if @store.user.discarded?
      flash[:notice] = "Unprocessable entity."
      render :show, status: :unprocessable_entity
    else
      @store.undiscard 
      redirect_to stores_path, notice: 'Store reactivated successfully.'
    end
  end

  # PATCH/PUT /stores/1 or /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to store_url(@store), notice: "Store was successfully updated." }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1 or /stores/1.json
  def destroy
    @store.discard!

    respond_to do |format|
      format.html { redirect_to stores_url, notice: "Store was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def theme_options
    render json: {
      themes: [
        { value: 'blue', label: 'Azul' },
        { value: 'red', label: 'Vermelho' },
        { value: 'green', label: 'Verde' },
        { value: 'yellow', label: 'Amarelo' },
        { value: 'purple', label: 'Roxo' },
        { value: 'brown', label: 'Marrom' },
        { value: 'pink', label: 'Rosa' },
        { value: 'orange', label: 'Laranja' },
        { value: 'lightblue', label: 'Azul claro' },
        { value: 'silver', label: 'Cinza' },
        { value: 'lavender', label: 'Lavanda' }
      ]
    }
  end

  def new_order
    response.headers["Content-Type"] = "text/event-stream"
    sse = SSE.new(response.stream, retry: 300, event: "waiting-orders")
    last_orders = nil
    begin
      sse.write({ hello: "world!" }, event: "waiting-order")
      EventMachine.run do
        EventMachine::PeriodicTimer.new(3) do
          orders = Order.where.not(state: [:canceled, :delivered, :payment_failed, :created, :payment_pending])
          if orders != last_orders 
            if orders.any?
              formatted_orders = orders.map do |order|
                buyer = order.buyer

                Rails.logger.info "Order: #{order.inspect}, Buyer: #{buyer.inspect}, Order Items: #{order.order_items.inspect}, Products: #{order.order_items.map(&:product).inspect}"
                {
                  id: order.id,
                  customerName: order.buyer.name,
                  status: order.state,
                  items: order.order_items.map { |item| { id: item.id, name: item.product.title, price: item.price } },
                  total: format_price(order.order_items.sum { |item| item.price * item.amount }),
                  address: "#{order.buyer.address}, #{order.buyer.numberaddress}",
                  neighborhood: order.buyer.neighborhood,
                  city: order.buyer.city,
                  cep: order.buyer.cep,
                  expanded: false
                }
              end
              message = { time: Time.now, orders: formatted_orders }
              sse.write(message, event: "new orders")
            else
              sse.write({ message: "no orders" }, event: "no")
            end
            last_orders = orders 
          end
        end
      end
    rescue IOError, ActionController::Live::ClientDisconnected
      sse.close
    ensure
      sse.close
    end
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    required = params.require(:store)

    if current_user.admin?
      required.permit(:name, :user_id, :image, :cnpj, :phonenumber, :city, :cep, :state, :neighborhood, :address, :numberaddress, :establishment, :complementadress, :active, :theme)
    else
      required.permit(:name, :image, :cnpj, :phonenumber, :city, :cep, :state, :neighborhood, :address, :numberaddress, :establishment, :complementadress, :active, :theme)
    end
  end

  def not_authorized(e)
    render json: { message: "Nope!" }, status: 401
  end

  def format_price(price)
    ActionController::Base.helpers.number_to_currency(price)
  end
end

