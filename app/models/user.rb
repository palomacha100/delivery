require 'dotenv/load'

class User < ApplicationRecord
  include Discard::Model
  has_many :refresh_tokens
  before_discard :anonymize_email
  validates :role, presence: true
  
  class InvalidToken < StandardError; end

  enum :role, [:admin, :seller, :buyer]
  has_many :store
  has_many :orders, foreign_key: 'buyer_id'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  def self.token_for(user)
    jwt_secret_key = Rails.application.credentials.jwt_secret_key
   

    jwt_headers = {exp: 1.hour.from_now.to_i}
    payload = {
       id: user.id,
       email: user.email,
       role: user.role
    }
    JWT.encode(
       payload.merge(jwt_headers),
       jwt_secret_key,
       "HS256"
    )
  end

  def self.from_token(token)
    jwt_secret_key = Rails.application.credentials.jwt_secret_key
    jwt_decode = (JWT.decode token, jwt_secret_key, true, { algorithm: 'HS256'})
      .first
      .with_indifferent_access
    jwt_decode
  rescue JWT::ExpiredSignature
    raise InvalidToken.new
  end

  private

  def anonymize_email
    domain = email.split('@').last
    self.email = "anon#{id}@#{domain}"
  end
  
end


