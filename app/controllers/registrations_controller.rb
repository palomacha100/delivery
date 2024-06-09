class RegistrationsController < ApplicationController
  skip_forgery_protection only: [:destroy, :create, :me, :sign_in, :refresh, :show, :update_user]
  before_action :authenticate!, only: [:me, :edit, :edit_user, :index, :active, :show]
  rescue_from User::InvalidToken, with: :not_authorized
 
  def me
    render json: {"email": current_user[:email], "id": current_user[:id] }
  end
 
  def sign_in
    access = current_credential.access
    user = User.kept.where(role: access).find_by(email: sign_in_params[:email])
    if !user || !user.valid_password?(sign_in_params[:password])
      render json: {message: "Nope!"}, status: 401
    else
      refresh_token = user.refresh_tokens.create!(expires_at: 30.days.from_now)
      token = User.token_for(user)
      render json: {email: user.email, token: token, refresh_token: refresh_token.refresh_token}
    end
  end

  def show
    current_user = authenticate_with_http_token { |token, options| User.from_token(token) }
    @user = User.find(current_user[:id])
  end
 
   def create
     @user = User.new(user_params)
     @user.role = current_credential.access
     email = params[:user][:email]
     if user_exists?(email)
         render json: { error: 'User already exists' }, status: :conflict
     else 
        if @user.save
          render json: { email: @user.email }
        else
          render json: {}, status: :unprocessable_entity
        end
     end
   end

   def active
    @user = User.find(params[:id])
    @user.undiscard 
    redirect_to users_path, notice: 'User reactivated successfully.'
   end

   def sign_up
    @user = User.new(sign_up_params)
      if @user.save
        redirect_to root_path, notice: 'User created successfully.'
      else
        render :new
      end
   end

   def index
    @users = User.all
   end

   def destroy
    if current_user && current_user.admin?
      user = User.find(params[:id])
        if user.discard!
          redirect_to users_path, notice: 'User deactivate successfully.'
        else
          flash[:alert] = 'User not deactivated.'
          redirect_to users_path
        end
      else
        current_user = authenticate_with_http_token { |token, options| User.from_token(token) }
        @user = User.find(current_user[:id])
        if @user.discard!
          render json: 'User deleted with success.' , status: :ok
        end
    end
  end

  def edit_user
    @user = User.find(params[:id])
    if @user.update(user_params_update)
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      render edit_path, notice: 'User not was successfully updated.'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def update_user
    current_user = authenticate_with_http_token { |token, options| User.from_token(token) }
    @user = User.find(current_user[:id])
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def refresh
    refresh_token = RefreshToken.find_by(refresh_token: params[:refresh_token])
    if refresh_token && refresh_token.expires_at > Time.current
      user = refresh_token.user
      token = User.token_for(user)
      render json: {email: user.email, token: token, refresh_token: refresh_token.refresh_token}, status: :ok
    else
      render json: { error: 'Invalid or expired refresh token' }, status: :unauthorized
    end
  end
 
    
   private
 
   def user_params
     params
      .required(:user)
      .permit(:email, :password, :password_confirmation, :name, :cpf, :phonenumber, :cep, :state, 
      :city, :neighborhood, :address, :numberaddress, :complementaddress)
   end

   def user_params_update
    params
      .required(:user)
      .permit(:email, :role)
  end
 
   def user_exists?(email)
       User.exists?(email: email)
   end
 
   def sign_in_params
    params.required(:login).permit(:email, :password)
   end
 
   def not_authorized(e)
     render json: {message: "Nope!"}, status: 401
   end

   def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end 
 end
 
 