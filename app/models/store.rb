class Store < ApplicationRecord
  include Discard::Model

  has_one_attached :image
  belongs_to :user
  before_validation :ensure_seller
  has_many :products
  validates :name, presence: true, length: {minimum: 3}
  validates :cnpj, presence: true, length: {is:14}, uniqueness: { message: "CNPJ já está em uso" }
  validates :phonenumber, presence: true, length: {minimum: 10, maximum: 11}
  validates :city, presence: true
  validates :cep, presence: true, length: {is:8}
  validates :state, presence: true
  validates :neighborhood, presence: true
  validates :address, presence: true
  validates :numberaddress, presence: true
  validates :establishment, presence: true
  validates :theme, presence: true

  private

  def ensure_seller
    self.user = nil if self.user && !self.user.seller?
  end
end
