class Store < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  before_validation :ensure_seller
  validates :name, presence: true, length: {minimum: 3}
  has_many :products

  private

  def ensure_seller
    self.user = nil if self.user && !self.user.seller?
  end
end
