class User < ApplicationRecord
  class InvalidToken < StandardError; end

  has_many :stores
  enum :role, [:admin, :seller, :buyer]
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.token_for(user)
    jwt_headers = {exp: 1.hour.from_now.to_i}
    payload = {id: user.id, email: user.email, role: user.role}
    JWT.encode payload.merge(jwt_headers), "muito.secreto", "HS256"
  end
  
  def self.from_token(t)
    decoded = JWT.decode t, "muito.secreto", true, {algorithm: 'HS256'}
    user_data = decoded[0].with_indifferent_access
    User.find(user_data[:id])
  rescue JWT::ExpiredSignature
    raise InvalidToken.new
  end
  
end

