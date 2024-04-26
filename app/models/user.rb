require 'dotenv/load'

class User < ApplicationRecord

  validates :role, presence: true
  # Include default devise modules. Others available are:
  # :confirm
  # able, :lockable, :timeoutable, :trackable and :omniauthable
  class InvalidToken < StandardError; end

  enum :role, [:admin, :seller, :buyer]
  has_many :store

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  def self.token_for(user)
    jwt_secret_key = Rails.application.credentials.jwt_secret_key_base
   

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
end


