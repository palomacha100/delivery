class Product < ApplicationRecord
  belongs_to :store
  has_many :orders, through: :order_items
  validates :name, presence: true, length: {minimum: 3}
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
