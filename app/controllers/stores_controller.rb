class StoresController < ApplicationController
  skip_forgery_protection only: %i[create update destroy]
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy ]
  rescue_from User::InvalidToken, with: :not_authorized

  # GET /stores or /stores.json
  def index
    if current_user.admin?
      @stores = Store.all
    elsif current_user.buyer?
      @stores = Store.kept.includes(image_attachment: :blob)
    else 
      @stores = Store.kept.where(user: current_user).includes(image_attachment: :blob)
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
      sse.write({ hello: "world!"}, event: "waiting-order")
      EventMachine.run do
        EventMachine::PeriodicTimer.new(3) do
         orders = Order.where.not(state: [:canceled, :delivered, :payment_failed, :created, :payment_pending])
        if orders != last_orders 
          if orders.any?
            message = { time: Time.now, orders: orders } 
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
        required.permit(:name, :user_id, :image, :cnpj, 
        :phonenumber, :city, :cep, :state, :neighborhood, 
        :address, :numberaddress, :establishment, :complementadress, :active, :theme)
      else
        required.permit(:name, :image, :cnpj, :phonenumber, 
        :city, :cep, :state, :neighborhood, :address, :numberaddress, :establishment, :complementadress, :active, :theme)
      end
    end

    def not_authorized(e)
      render json: {message: "Nope!"}, status: 401
    end
end
